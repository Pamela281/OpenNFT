function ptbPreparation(screenId, workFolder, protName)
% Function to prepare PTB parameters to use them during setup and
% run-time within the Matlab Helper process.
%
% input:
% screenId   - screen number from GUI ('Display Feedback on')
% workFolder - path to work folder to get the Settings and picture sets to
%              load
% protName   - name of the neurofeedback protocol from GUI
%
% output:
% Output is assigned to workspace variables.
%
% Note, synchronization issues are simplified, e.g. sync tests are skipped.
% End-user is adviced to configure the use of PTB on their own workstation
% and justify more advanced configuration for PTB.
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% Written by Yury Koush

P = evalin('base', 'P');

isCONT = strcmp(P.Prot, 'Cont');  % save whether feedback is continuous

Screen('CloseAll');
Screen('Preference', 'SkipSyncTests', 2);

if ~ismac
    % Because this command messes the coordinate system on the Mac OS
    Screen('Preference', 'ConserveVRAM', 64);
end

AssertOpenGL();

myscreens = Screen('Screens');
if length(myscreens) == 3
    % two monitors: [0 1 2]
    screenid = myscreens(screenId + 1);
elseif length(myscreens) == 2
    % one monitor: [0 1]
    screenid = myscreens(screenId);
else
    % if different, configure your mode
    screenid = 0;
end

fFullScreen = P.DisplayFeedbackFullscreen;

if ~fFullScreen
    % part of the screen, e.g. for test mode
    if strcmp(protName, 'Cont')
        [P.Screen.wPtr,P.Screen.wRect] = Screen('OpenWindow', screenid, 0, ... %125 125 125
            [40 40 640 520]);
    else
        [P.Screen.wPtr,P.Screen.wRect] = Screen('OpenWindow', screenid, 0, ...
            [40 40 720 720]);
    end
else
    % full screen
    [P.Screen.wPtr,P.Screen.wRect] = Screen('OpenWindow', screenid, 0); % 200 200 200
end

[w, h] = Screen('WindowSize', P.Screen.wPtr);
P.Screen.ifi = Screen('GetFlipInterval', P.Screen.wPtr);
[P.xCenter, P.yCenter] = RectCenter(P.Screen.wRect);

%get some color information
P.Screen.white = WhiteIndex(screenid);
P.Screen.black = BlackIndex(screenid);
P.Screen.grey = P.Screen.white/2;

% settings
P.Screen.vbl=Screen('Flip', P.Screen.wPtr);
P.Screen.h = h;
P.Screen.w = w;
P.Screen.lw = 5;

% Text "HELLO" - also to check that PTB-3 function 'DrawText' is working
% Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
% Screen('DrawText', P.Screen.wPtr, 'BONJOUR', ...
%     floor(P.Screen.w/2-P.Screen.h/6), ...
%     floor(P.Screen.h/2-P.Screen.h/10), [200 200 200]);
% P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
% 
% pause(1)

% preliminary stuff response key

while KbCheck
end

%input parameter

KbName('UnifyKeyNames');

run_time = datestr(clock,'yyyy_mm_dd__HH_MM');

%% TXT file
if isCONT
    run_filename = sprintf('sub-%s_motorNF_run-%d_rawevents_%s.tsv', ...
    P.SubjectID, P.NFRunNr, run_time);

    [P.Motor_onset, message] = fopen([workFolder filesep 'Onsets' filesep run_filename],'w');

    if P.Motor_onset < 0
        error('Failed to open myfile because: %s', message);
    end

    fprintf(P.Motor_onset, 'Subject_Number:\t%s\n', P.SubjectID);                       % write Subject ID into StimuliFile
    fprintf(P.Motor_onset, 'Date\t%s\n', datestr(clock, 1));                     % write Date in StimuliFile
    fprintf(P.Motor_onset, 'Time\t%s\n', datestr(clock, 13));                    % write Time in StimuliFile
    fprintf(P.Motor_onset, '\n');                                                % insert one carriage returns in StimuliFile
    fprintf(P.Motor_onset, 'ID\trun\tproject_type\tfb_type');
    fprintf(P.Motor_onset, '\tcondition\tonset_trial\tfb_value\tstim_start\n'); % Headers
% 
%     fprintf(P.Motor_onset, 'condition\tonsets_seconds\n');
%     P.condition_motor = ["hold" "move" "instructions" "instructions" "instructions" "instructions" ...
%         "instructions" "instructions"];
    %P.condition_motor = ["instructions" "hold" "move"];
else
    
    run_filename = sprintf('sub-%s_emoNF_run-%d_rawevents_%s.tsv', ...
    P.SubjectID, P.NFRunNr, run_time);

%     [P.StimuliFile_NF, message] = fopen([workFolder filesep 'Onsets' filesep 'NF_BD_emo_' ...
%         'sub-' P.SubjectID '_' num2str(P.NFRunNr) '.txt'],'w');
    [P.StimuliFile_NF, message] = fopen([workFolder filesep 'Onsets' filesep run_filename],'w');
    
    if P.StimuliFile_NF < 0
       error('Failed to open myfile because: %s', message);
    end
    
    fprintf(P.StimuliFile_NF, 'Subject_Number:\t%s\n', P.SubjectID);                       % write Subject ID into StimuliFile
    fprintf(P.StimuliFile_NF, 'Date\t%s\n', datestr(clock, 1));                     % write Date in StimuliFile
    fprintf(P.StimuliFile_NF, 'Time\t%s\n', datestr(clock, 13));                    % write Time in StimuliFile
    fprintf(P.StimuliFile_NF, '\n');                                                % insert one carriage returns in StimuliFile
    fprintf(P.StimuliFile_NF, 'ID\trun\tproject_type\tfb_type');
    fprintf(P.StimuliFile_NF, '\ttrial_type\tonset\timage_name\tfb_value\tresponse_key_baseline\tstim_start\n'); % Headers

end

%{
P.condition_instruction = "instructions"; ...
    P.condition_neutral = "neutre"; P.condition_regulation = "regulation";...
    P.condition_jauge = "jauge"; P.condition_fixation_cross = "croix de fixation";

P.condition = [P.condition_instruction P.condition_neutral P.condition_regulation ...
    P.condition_jauge P.condition_fixation_cross];
%}

%Text "BONJOUR" - also to check that PTB-3 function 'DrawFormattedText" is working
%{
welcome1 = 'Bonjour';
welcome2 = '\n Bienvenue dans cette expérience';
welcome3 = '\n \n Essayez de ne pas bouger la tête';
%}

Screen('TextSize', P.Screen.wPtr, 50);
DrawFormattedText(P.Screen.wPtr, 'Bonjour et bienvenue', ...
    'center', P.Screen.h * 0.45, 255); %0
[P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
P.TTLonsets = GetSecs;

if isCONT
    fprintf(P.Motor_onset, '%s\t', P.SubjectID);                                         % subject
    fprintf(P.Motor_onset, '%d\t', P.NFRunNr);                                           % run_id
    fprintf(P.Motor_onset, '%s\t', P.ProjectName);                                        % project_name
    fprintf(P.Motor_onset, '%s\t', P.Prot);                                              %fb_type (inter/cont)
    fprintf(P.Motor_onset, '%s\t', 'instruction');
    fprintf(P.Motor_onset, '%f\t', StimulusOnsetTime - P.TTLonsets);
    fprintf(P.Motor_onset, '%d\t', 0);                                           %feedback value
    fprintf(P.Motor_onset, '%d\n', P.TTLonsets);                                          % stimulation_start

%     fprintf(P.Motor_onset, '%s\t %s\t\n', P.condition_motor(3),  '0');
else
    roiDir = fullfile(workFolder,'Mask_ROI_fronto_limbic'); weightDir = fullfile(P.WorkFolder,'W1');
    P.roiNames = cellstr([spm_select('FPList', roiDir, '^.*.img$'); ...
        spm_select('FPList', roiDir, '^.*.nii$')]);
    P.weightName = cellstr([spm_select('FPList', weightDir, '^.*.img$'); ...
        spm_select('FPList', weightDir, '^.*.nii$')]);

    fprintf(P.StimuliFile_NF, '%s\t', P.SubjectID);                                         % subject
    fprintf(P.StimuliFile_NF, '%d\t', P.NFRunNr);                                           % run_id
    fprintf(P.StimuliFile_NF, '%s\t', P.ProjectName);                                        % project_name
    fprintf(P.StimuliFile_NF, '%s\t', P.Prot);                                              %fb_type (inter/cont)
    fprintf(P.StimuliFile_NF, '%s\t', 'instruction');
    fprintf(P.StimuliFile_NF, '%f\t', 0);
    fprintf(P.StimuliFile_NF, '%s\t', 'NaN');                                               % image name
    fprintf(P.StimuliFile_NF, '%d\t', 0);                                           %feedback value
    fprintf(P.StimuliFile_NF, '%s\t', 'NaN');                                           %response_key
    fprintf(P.StimuliFile_NF, '%d\n', P.TTLonsets);                                          % stimulation_start
% 
%     fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t %s\t\n', P.condition_emo(1),  StimulusOnsetTime - P.TTLonsets,...
%         'NA','NA');
end

% Each event row for PTB is formatted as
% [t9, t10, displayTimeInstruction, displayTimeFeedback]
P.eventRecords = [0, 0, 0, 0];

%% PSC
if strcmp(protName, 'Cont')
    % fixation
    P.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
    Screen('FillOval', P.Screen.wPtr, [255 255 255], P.Screen.fix);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
    Tex = struct;
end

if strcmp(protName, 'ContTask')
    % Set up alpha-blending for smooth (anti-aliased) lines
    Screen('BlendFunction', P.Screen.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % fixation cross settings
    P.Screen.fixCrossDimPix = 40;
    
    % Set the line width for fixation cross
    P.Screen.lineWidthPix = 4;

    % Setting the coordinates
    P.Screen.wRect = [0, 0, P.Screen.w, P.Screen.h];
    [P.Screen.xCenter, P.Screen.yCenter] = RectCenter(P.Screen.wRect);
    P.Screen.xCoords = [-P.Screen.fixCrossDimPix P.Screen.fixCrossDimPix 0 0];
    P.Screen.yCoords = [0 0 -P.Screen.fixCrossDimPix P.Screen.fixCrossDimPix];
    P.Screen.allCoords = [P.Screen.xCoords; P.Screen.yCoords];
    
    % scramble-image presentation parameters
    P.Screen.numSecs = 1;    % presentation dur in sec (500ms)
    P.Screen.numFrames = round(P.Screen.numSecs / P.Screen.ifi);    % in frames
    
    % get some color information
    P.Screen.white = WhiteIndex(screenid);
    P.Screen.black = BlackIndex(screenid);
    P.Screen.grey  = P.Screen.white / 2;

    % response option coords on the x and y axis relative to center 
    P.Screen.option_lx = -250;    % left option     x
    P.Screen.option_rx = 150;     % right option    x
    P.Screen.option_ly = 300;     % left option     y
    P.Screen.option_ry = 300;     % right option    y
    
    % accepted response keys
    P.Screen.leftKey = KbName('1');
    P.Screen.rightKey = KbName('2');

    % show initial fixation dot
    P.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
    Screen('FillOval', P.Screen.wPtr, [255 255 255], P.Screen.fix);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);

    %% Prepare PTB Sprites
    stimPath = P.TaskFolder;
    load([stimPath filesep 'stimNames.mat'])
    
    sz = size(stimNames,2);             % nr of unique images
    P.Screen.nrims = 10;                % how many repetitions of an image
    Tex = zeros(sz,P.Screen.nrims);     % initialize pointer matrix
    for i = 1:sz
        for j = 1:P.Screen.nrims 
            imgArr = imread([stimPath filesep stimNames{i} filesep num2str(j) '.png']);
            Tex(i,j) = Screen('MakeTexture', P.Screen.wPtr, imgArr);
            clear imgArr
        end
    end
    
    % text font, size and style
    Screen('TextFont',P.Screen.wPtr, 'Courier New');
    Screen('TextSize', P.Screen.wPtr, 12);
    Screen('TextStyle',P.Screen.wPtr, 3);
    
    % initiate trial counter variable for keeping track of task trials.
    % Counter values will be used to index images in texture pointer mat.
    P.Task.trialCounter = 1;
   
end

% Intermittent SVM
if strcmp(protName, 'Inter')
    localisation = questdlg('Where are you ?',...
    'localisation',...
    'Paris', 'Grenoble','Bordeaux', 'Paris');

    switch localisation
        case 'Paris'
            disp(['You are in' localisation])
            localisation = 'Paris';
        case 'Grenoble'
            disp(['You are in' localisation])
            localisation = 'Grenoble';
        case 'Bordeaux'
            disp(['You are in' localisation])
            localisation = 'Bordeaux';
    end


    device = questdlg('Are you on your PC or at the MRI console ?',...
    'Device',...
    'MRI console', 'PC','PC');

    % Handle response
    switch device
        case 'MRI console'
            disp([' You are at the ' device])
            device = 1;
        case 'PC'
            disp([' You are on your ' device])
            device = 2;
    end

%     if device == 1
%         P.device_buttons = 'Arduino LLC Arduino Leonardo';
%     elseif device == 2
%         P.device_buttons = 'AT Translated Set 2 keyboard'; %clavier
%     end

    session = questdlg('Is it a neurofeedback session or a transfert session ?', ...
    'Session',...
    'Neurofeedback', 'Transfert', 'Neurofeedback');

    % Handle response
    switch session
        case 'Neurofeedback'
            disp(' This is a neurofeedback session ')
            P.session = 1;
        case 'Transfert'
            disp(' This is a transfert session ')
            P.session = 2;
    end

%{
    if session == 1
        P.session = 'Neurofeedback';
    elseif device == 2
        P.device_buttons = 'Clavier';
    end
%}

%     responseKeys  = [KbName('k') KbName('j')]; %j = index, k = majeur
% 
%     [keyboardIndices, productNames, allInfos] = GetKeyboardIndices;
%     [logicalKey,locationKey]=ismember({P.device_buttons},productNames); % push buttons
%     P.deviceIndex_buttons=allInfos{locationKey}.index;
% 
%     keysOfInterest = zeros (1,256);
%     keysOfInterest(responseKeys) = 1;
%     KbQueueCreate(P.deviceIndex_buttons, keysOfInterest);
%     KbQueueStart(P.deviceIndex_buttons);
% 
%     P.answer = '';
% 
%     % start listening to key input
%     KbQueueCreate();
%     KbQueueStart();

    % Images
    imageFormat = 'jpg';

%{
    if device == 1
        P.image_neutral_condition = [workFolder filesep '..' filesep ...
            '..' filesep '..' filesep 'Images_NFB' filesep 'NFB' filesep 'images_neu']; %to change
    elseif device == 2
        P.image_neutral_condition = [workFolder filesep '..' filesep ...
            '..' Images_NFB' filesep 'NFB' filesep 'images_neu']; %to change
%}

    
    % Neutral condition
   %{
 P.image_neutral_condition = [workFolder filesep '..' filesep ...
            '..' filesep '..' filesep 'Images_NFB' filesep 'NFB' filesep 'images_neu']; %to change
    imgList_neutral_condition = dir(fullfile(P.image_neutral_condition,['*' imageFormat]));
    P.imgList_neutral_condition = {imgList_neutral_condition(:).name};
    nTrials_neutral = length(P.imgList_neutral_condition);
    
    P.randomizedTrials_neutral = randperm(nTrials_neutral);
    P.neutral_image_idx = 1;
%}
    load(fullfile([workFolder filesep '..' filesep ...
            '..' filesep 'matrice_randomisation_NFB_' localisation '.mat']));

    renamed_image_path = [workFolder filesep '..' filesep ...
        '..' filesep '..' filesep 'Images_NFB' filesep 'NFB'];

    P.tmp_count_neut = 0;
    P.image_counter  = 0;
%     P.image_counter_neg = 0;
    P.tmp_count_neg = 0;
    subject_col = 1;
    session_col = 2;
    run_col = 3;
    block_col = 4;
    image_num_col = 5;
    ordre_apparition_valences_col = 6;
    valence_col = 7;
    image_file_num_col = 8;

    this_run = matrice_randomisation(find(matrice_randomisation(:,subject_col) == str2num(P.SubjectID) & ...
    matrice_randomisation(:,session_col) == 1 & matrice_randomisation(:,run_col) == P.NFRunNr), :);

    valence_folders = {'NEU','NEG'};
    texture = [];
    image_ID = {};

    for i = 1:size(this_run,1)

    valence_rep = valence_folders{this_run(i, valence_col)};               % valence
    P.image_filename = sprintf('%s_%03d.jpg', upper(valence_rep), this_run(i, image_file_num_col));
    image_filepath = fullfile(renamed_image_path, valence_rep, P.image_filename);

       try
                image = imread(image_filepath);
            catch pb_imread
                sca
                fprintf('filename: %s\nProblem: %s\n', image_filepath, pb_imread.message);
                break
       end

    P.texture(i) = Screen('MakeTexture',P.Screen.wPtr , image);
    P.image_ID{i} = P.image_filename;
    end

    % regulation condition stimuli
     %{
P.image_regulation_condition = [workFolder filesep '..' filesep ...
        '..' filesep '..' filesep 'Images_NFB' filesep 'NFB' filesep 'images_neg']
    imgList_regulation_condition = dir(fullfile(P.image_regulation_condition,['*' imageFormat]));
    P.imgList_regulation_condition ={imgList_regulation_condition(:).name};
    nTrials_regulation = length(P.imgList_regulation_condition);

    P.randomizedTrials_regulation = randperm(nTrials_regulation);
    P.regulation_image_idx = 1;
%}

%     % accepted response keys
%     P.Screen.indexKey = responseKeys(2);
%     P.Screen.majorKey = responseKeys(1);

    %P.indoor.answer = '';
    %P.outdoor.answer = '';
%     P.answer = '';
% 
%     [keyIsDown, keyCode] = KbQueueCheck(deviceIndex_buttons);
%     if keyIsDown
%         if keyCode(P.Screen.indexKey) ~= 0
%             P.answer = "indoor"; % Indoor images
%             P.indoor.answer = 'indoor'
%             disp('ok index')
%         elseif keyCode(P.Screen.majorKey) ~= 0
%             P.answer = "outdoor";  % Outdoor images
%             disp('ok majeur')
%         end
%     end

end

% 
% % PSC intermittent
% if strcmp(protName, 'Inter')
%     for i = 1:10
%         imgSm = imread([workFolder filesep 'Settings' filesep ...
%             'Smiley' filesep 'Sm' sprintf('%02d', i)], 'bmp');
%         Tex(i) = Screen('MakeTexture', P.Screen.wPtr, imgSm);
%         clear imgSm
%     end
%     P.Screen.rectSm = Screen('Rect', Tex(i));
%     
%     w_dispRect = round(P.Screen.rectSm(4)*1.5);
%     w_offset_dispRect = 0;
%     P.Screen.dispRect =[(w/2 - w_dispRect/2), ...
%         (h/2 + w_offset_dispRect), (w/2 + w_dispRect/2), ...        
%         (h/2 + w_offset_dispRect+w_dispRect)];
%     
%     %% Dots
%     % MRI screen parameters
%     dist_mri = 44.3; % distance to the screen, cm
%     scrw_mri = [34.8 25.8]; % cm
%     
%     % MRI screen scaling
%     screenpix = [w h]; %pixel resolution
%     screen_VA = [( 2 * atan(scrw_mri(1) / (2*dist_mri)) ), ...
%         ( 2 * atan(scrw_mri(2) / (2*dist_mri)) )]; % the screens visual 
%     % angle in radians
%     screen_VA = screen_VA * 180/pi; % the screens visual angle in degrees
%     degrees_per_pixel = screen_VA ./ screenpix; % degrees per pixel
%     degrees_per_pixel_mean = mean(degrees_per_pixel); % approximation of 
%     % the average number of degrees per pixel
%     pixels_per_degree = 1 ./ degrees_per_pixel;
%     pixels_per_degree_mean = 1 ./ degrees_per_pixel_mean;
%     
%     % circle prescription, via dots
%     ddeg = 1:10:360; % degree
%     drad = ddeg * pi/180; % rad
%     P.Screen.dsize = 5; % dot size
%     cs = [cos(drad); sin(drad)];
%     % dot positions
%     d=round(P.TargDIAM .* pixels_per_degree_mean);
%     P.Screen.xy = cs * d / 2;
%     r_offset = P.TargRAD * pixels_per_degree(1);
%     loc_xy = round(r_offset * [cosd(P.TargANG) sind(P.TargANG)]);
%     P.Screen.db = [w/2 h/2] + [+loc_xy(1)  -loc_xy(2)];
%     
%     % color
%     P.Screen.dotCol = 200;
%     
%     % fixation
%     P.Screen.fix = [w/2-w/150, h/2-w/150, w/2+w/150, h/2+w/150];
%     Screen('FillOval', P.Screen.wPtr, [155 0 0], P.Screen.fix);
%     P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
%     
%     % pointing arrow
%     P.Screen.arrow.rect = [w/2-w/100, h/2-w/40, w/2+w/100, h/2-w/52];
%     P.Screen.arrow.poly_right = [w/2+w/100, h/2-w/32; ...
%         w/2+w/50,  h/2-w/46; w/2+w/100, h/2-w/74];
%     P.Screen.arrow.poly_left  = [w/2-w/100, h/2-w/32; ...
%         w/2-w/50,  h/2-w/46; w/2-w/100, h/2-w/74];
%     
%     Screen('TextSize',P.Screen.wPtr, 100);
%     
%     %%
%     fName = [workFolder filesep 'Settings' filesep 'NF_PCS_int_FT_run_' sprintf('%d',P.NFRunNr) '.json'];
%     prt = loadjson(fName);
% 
%     vectList = zeros(603,1);
%     wordList = strings(603,1);
% 
%     load([workFolder filesep 'Settings' filesep 'WORDS_Run_' sprintf('%d',P.NFRunNr) '.mat']);
%     load([workFolder filesep 'Settings' filesep 'NOWORDS_Run_' sprintf('%d',P.NFRunNr) '.mat']);
% 
%     for i = 1:6
%         tmpOnstes = prt.Cond{i}.OnOffsets;
%         tmpName = prt.Cond{i}.ConditionName;
%         lOnsets = size(tmpOnstes,1);
%         kW = 0; kNW = 0;
%         for iOn = 1:lOnsets
%             newOnsets = tmpOnstes(iOn,1):2:tmpOnstes(iOn,2)-1;
%             if strcmp(tmpName,'READW')
%                 vectList(newOnsets) = 1;
% 
%                 for iStim = 1:length(newOnsets)
%                     kW = kW + 1;
%                     wordList(newOnsets(iStim)) = WORDS(kW);
%                 end
% 
%             elseif strcmp(tmpName,'READNW')
%                 vectList(newOnsets) = 2;
% 
%                 for iStim = 1:length(newOnsets)
%                     kNW = kNW + 1;
%                     wordList(newOnsets(iStim)) = NOWORDS(kNW);
%                 end
% 
%             end
% 
%         end
%     end
%     P.vectList = vectList;
%     P.wordList = wordList;
% end

%% DCM
% Note that images are subject of copyright and thereby replaced.
% Note that pictures and names are not randomized in our example for
% simplicity. The randomization could be done on the level of
% namePictP.mat and namePictN.mat structures given unique pictures per
% NF run in .\nPict and .\nPict folders.
if strcmp(protName, 'InterBlock')
    
    P.nrN = 0;
    P.nrP = 0;
    P.imgPNr = 0;
    P.imgNNr = 0;
    
    %% Prepare PTB Sprites
    % positive pictures
    basePath = strcat(workFolder, filesep, 'Settings', filesep);
    load([basePath 'namePictP.mat']);
    sz = size(namePictP,1);
    Tex.P = zeros(1,sz);
    for i = 1:sz
        fname = strrep(namePictP(i,:), ['.' filesep], basePath);
        imgArr = imread(fname);
        dimImgArr = size(imgArr);
        Tex.P(i) = Screen('MakeTexture', P.Screen.wPtr, imgArr);
        clear imgArr
    end
    
    % neutral pictures
    basePath = strcat(workFolder, filesep, 'Settings', filesep);
    load([basePath 'namePictN.mat']);
    sz = size(namePictN,1);
    Tex.N = zeros(1,sz);
    for i = 1:sz
        fname = strrep(namePictN(i,:), ['.' filesep], basePath);
        imgArr = imread(fname);
        dimImgArr = size(imgArr);
        Tex.N(i) = Screen('MakeTexture', P.Screen.wPtr, imgArr);
        clear imgArr
    end
    
    % text font, style and size
    Screen('TextFont',P.Screen.wPtr, 'Courier New');
    Screen('TextSize',P.Screen.wPtr, 40);
    Screen('TextStyle',P.Screen.wPtr, 3);
    
    %% Draw initial fixation
    Screen('FillOval', P.Screen.wPtr, [150 150 150], ...
        [P.Screen.w/2-w/100, P.Screen.h/2-w/100, ...
        P.Screen.w/2+w/100, P.Screen.h/2+w/100]);
    P.Screen.vbl=Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
end

%fclose(P.StimuliFile_NF);
assignin('base', 'P', P);
%assignin('base', 'Tex', Tex);

