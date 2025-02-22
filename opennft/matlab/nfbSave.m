function nfbSave(indVol)
% Function to clear workspase and save the necessary information.
%
% input:
% indVol - volume(scan) index
% Workspace variables.
%
% output:
% Output is a storage into the neurofeedback run directory.
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% Written by Yury Koush, Artem Nikonorov

disp('Save...')

P = evalin('base', 'P');
mainLoopData = evalin('base', 'mainLoopData');


if P.UseTCPData
    tcp = evalin('base', 'tcp');
    tcp.CloseConnection;
end

[isPSC, isDCM, isSVM, isIGLM] = getFlagsType(P);

folder = P.nfbDataFolder;

% save rtqa data
if P.isRTQA
    rtQA_matlab = evalin('base', 'rtQA_matlab');
    rtQA_python = evalin('base', 'rtQA_python');
    rtQAMode = evalin('base', 'rtQAMode');
    save([folder '\rtQA_matlab.mat'], '-struct', 'rtQA_matlab');
    save([folder '\rtQA_python.mat'], '-struct', 'rtQA_python');
end

% % save last volume stat data for offline access
if mainLoopData.statMapCreated
    slNrImg2DdimX = mainLoopData.slNrImg2DdimX;
    slNrImg2DdimY = mainLoopData.slNrImg2DdimY;
    img2DdimX = mainLoopData.img2DdimX;
    img2DdimY = mainLoopData.img2DdimY;
    dimVol = mainLoopData.dimVol;
    tn = mainLoopData.tn;
    indVolIglmIndx = length(mainLoopData.idxActVoxIGLM.pos);
    idxActVoxIGLM.pos = mainLoopData.idxActVoxIGLM.pos{indVolIglmIndx};
    statMap3D_pos = mainLoopData.statMap3D_pos;
    statMap3D_neg = mainLoopData.statMap3D_neg;

    maskedStatMapVect = tn.pos(idxActVoxIGLM.pos);
    maxTval = max(maskedStatMapVect);
    if isempty(maxTval)
        maxTval = 1;
    end
    statMapVect = maskedStatMapVect;
    statMap3D_pos(idxActVoxIGLM.pos) = statMapVect;

    statMap2D_pos = vol3Dimg2D(statMap3D_pos, slNrImg2DdimX, slNrImg2DdimY, img2DdimX, img2DdimY, dimVol) / maxTval;
    statMap2D_pos = statMap2D_pos * 255;

    idxActVoxIGLM.neg = mainLoopData.idxActVoxIGLM.neg{indVolIglmIndx};
    maskedStatMapVect = tn.neg(idxActVoxIGLM.neg);
    maxTval = max(maskedStatMapVect);
    if isempty(maxTval)
        maxTval = 1;
    end
    statMapVect = maskedStatMapVect;
    statMap3D_neg(idxActVoxIGLM.neg) = statMapVect;

    statMap2D_neg = vol3Dimg2D(statMap3D_neg, slNrImg2DdimX, slNrImg2DdimY, img2DdimX, img2DdimY, dimVol) / maxTval;
    statMap2D_neg = statMap2D_neg * 255;

    mainLoopData.statMap2D_pos = statMap2D_pos;
    mainLoopData.statMap2D_neg = statMap2D_neg;

    m = evalin('base', 'mmStatVol');
    m.Data.posStatVol = statMap3D_pos;   
    assignin('base', 'mainLoopData', mainLoopData);
    
    m_out =  evalin('base', 'mmStatMap');
    m_out.Data.statMap = uint8(statMap2D_pos);
    
    m_out =  evalin('base', 'mmStatMap_neg');
    m_out.Data.statMap_neg = uint8(statMap2D_neg);
    assignin('base', 'statMap_neg', statMap2D_neg);
    
    if P.isRTQA
        n = mainLoopData.indVolNorm;
        var = rtQA_matlab.snrData.m2Smoothed ./ double(n-1);
        rtQA_matlab.snrData.snrVol = rtQA_matlab.snrData.meanSmoothed ./ (var.^.5);
        if ~P.isRestingState
            meanBas = rtQA_matlab.cnrData.basData.meanSmoothed;
            meanCond = rtQA_matlab.cnrData.condData.meanSmoothed;
            varianceBas = rtQA_matlab.cnrData.basData.m2Smoothed / (rtQA_matlab.cnrData.basData.iteration - 1);
            varianceCond = rtQA_matlab.cnrData.condData.m2Smoothed / (rtQA_matlab.cnrData.condData.iteration - 1);
            rtQA_matlab.cnrData.cnrVol = (meanCond - meanBas) ./ ((varianceBas + varianceCond).^.5);
        end;

        assignin('base', 'rtQA_matlab', rtQA_matlab);
     end
    
end

% save feedback values
if ~P.isRestingState
    % check if vectNFBs exists
    if sum(strcmp(fieldnames(mainLoopData), 'vectNFBs')) == 1
        save([folder filesep 'sub-' P.SubjectID '_' ...
            P.ProjectName '_' num2str(P.NFRunNr) '_NFBs' '.mat'], ...
            '-struct', 'mainLoopData', 'vectNFBs'); %add 24012022
    end
end

% save time-series
if P.NrROIs >0
    save([folder filesep 'sub-' P.SubjectID '_' ...
        P.ProjectName '_' num2str(P.NFRunNr) '_raw_tsROIs' '.mat'], ...
        '-struct', 'mainLoopData', 'rawTimeSeries'); %add 24012022
    save([folder filesep 'sub-' P.SubjectID '_' ...
        P.ProjectName '_' num2str(P.NFRunNr) '_proc_tsROIs' '.mat'], ...
        '-struct', 'mainLoopData', 'kalmanProcTimeSeries'); %add 24012022
end

%% Configuration
% save parameters
save([folder filesep 'sub-' P.SubjectID '_' ...
    P.ProjectName '_' num2str(P.NFRunNr) '_mainLoopData' '.mat'],'-struct','mainLoopData'); %add 24012022
save([folder filesep 'sub-' P.SubjectID '_' ...
    P.ProjectName '_' num2str(P.NFRunNr) '_P' '.mat'], '-struct', 'P'); %add 24012022

% save ROIs
if isPSC || isSVM
    roiData.ROIs = evalin('base', 'ROIs');
end
if isDCM
    roiData.ROIsAnat = evalin('base', 'ROIsAnat');
    roiData.ROIsGroup = evalin('base', 'ROIsGroup');
    roiData.ROIsGlmAnat = evalin('base', 'ROIsGlmAnat');
    roiData.ROIoptimGlmAnat = evalin('base', 'ROIoptimGlmAnat');
end
if ~P.isRestingState
    save([folder filesep 'sub-' P.SubjectID '_' ...
        P.ProjectName '_' num2str(P.NFRunNr) '_roiData' '.mat'], 'roiData'); %add 24012022
end

%% Results
if isfield(mainLoopData, 'vectNFBs')
    
    % save feedback values
    save([folder filesep 'sub-' P.SubjectID '_' ...
        P.ProjectName '_' num2str(P.NFRunNr) '_NFBs' '.mat'], ...
        '-struct', 'mainLoopData', 'vectNFBs'); %add 24012022
    
    % save time-series
    if P.NrROIs >0
        save([folder filesep 'sub-' P.SubjectID '_' ...
            P.ProjectName '_' num2str(P.NFRunNr) '_raw_tsROIs' '.mat'], ...
            '-struct', 'mainLoopData', 'rawTimeSeries'); %add 24012022
        save([folder filesep 'sub-' P.SubjectID '_' ...
            P.ProjectName '_' num2str(P.NFRunNr) '_proc_tsROIs' '.mat'], ...
            '-struct', 'mainLoopData', 'kalmanProcTimeSeries'); %add 24012022
    end
    
    % save reward values
    if strcmp(P.Prot, 'Inter') && strcmp(P.Type, 'PSC')
        % save reward vector for subsequent NF run, i.e. it becomes previous
        if isfield(P, 'actValue')
            prev_actValue = P.actValue;
        else
            prev_actValue = 0;
            fprintf('\nCheck Reward algorithm!\n');
        end
        save([folder filesep 'reward_' sprintf('%02d',P.NFRunNr) '.mat'], ...
            'prev_actValue');
    end
    
    % save activation map(s)
    %folder = P.nfbDataFolder;
    %folder = [P.WorkFolder filesep 'Pilot' filesep P.SubjectID filesep 'NF_Data_' P.SubjectID '_' P.ProjectName '_' num2str(P.NFRunNr)];
    if ~isempty(mainLoopData.statMap3D_iGLM)
        if ~isDCM
            statVolData = mainLoopData.statMap3D_iGLM;
            save([folder filesep 'sub-' P.SubjectID '_' P.ProjectName '_' num2str(P.NFRunNr) 'statVolData_' ...
                sprintf('%02d',P.NFRunNr) '.mat'], 'statVolData');
        else
            for iDcmBlock = 1: size(mainLoopData.statMap3D_iGLM,4)
                statVolData = ...
                    squeeze(mainLoopData.statMap3D_iGLM(:,:,:, iDcmBlock));
                save([folder filesep 'sub-' P.SubjectID '_' P.ProjectName '_' num2str(P.NFRunNr) 'statVolData_' ...
                    sprintf('%02d',iDcmBlock) '.mat'],'statVolData');
            end
        end
    end
    
    % concatenate two TimeVector event files
    fileTimeVectors_display = [folder 'sub-' P.SubjectID '_' P.ProjectName '_' num2str(P.NFRunNr) filesep 'TimeVectors_display_' ...
        sprintf('%02d', P.NFRunNr) '.txt'];
    
    if ~isSVM && exist(fileTimeVectors_display, 'file')
        recs = load([folder filesep 'sub-' P.SubjectID '_' P.ProjectName '_' num2str(P.NFRunNr) 'TimeVectors_' ...
            sprintf('%02d', P.NFRunNr) '.txt']);
        recsDisplay = load(fileTimeVectors_display);
        sz = size(recs);
        % Times.t9 and Times.t10
        tmpVect = 1:size(recsDisplay,1);
        recs(tmpVect, 10:11) = recsDisplay(:,1:2);
        % Abs Matlab PTB Helper times for display
        recs(tmpVect, sz(2)+1:sz(2)+2) = recsDisplay(:,3:4);
        save([folder filesep 'sub-' P.SubjectID '_' P.ProjectName '_' num2str(P.NFRunNr) 'TimeVectors_' ...
            sprintf('%02d', P.NFRunNr) '.txt'], 'recs', '-ascii', '-double');
    end
    
end

%fclose(P.StimuliFile_NF);
disp('Saving done')

% Clear workspace
evalin('base', 'clear mmImgViewTempl;');
evalin('base', 'clear mmStatVol;');
evalin('base', 'clear mmOrthView;');


