function displayFeedback(displayData)
% Function to display feedbacks using PTB functions
%
% input:
% displayData - input data structure
%
% Note, synchronization issues are simplified, e.g. sync tests are skipped.
% End-user is adviced to configure the use of PTB on their own workstation
% and justify more advanced configuration for PTB.
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% Written by Yury Koush, Artem Nikonorov

tDispl = tic;

P = evalin('base', 'P');
%Tex = evalin('base', 'Tex');

% Note, don't split cell structure in 2 lines with '...'.
fieldNames = {'feedbackType', 'condition', 'dispValue','Reward', 'displayStage','displayBlankScreen', 'iteration'};
defaultFields = {'', 0, 0, '', '', '', 0};
disp(displayData)
eval(varsFromStruct(displayData, fieldNames, defaultFields))

if ~strcmp(feedbackType, 'PSC') %Default : 'DCM'
    dispColor = [255, 255, 255];
    instrColor = [155, 150, 150];
    textSizeInstr = 50;
end
%{

logfile = fopen('C:\Users\pp262170\Documents\NFB_experiment\displayfeedback_log.txt', 'a');
fprintf(logfile, '%s: feedback=%s, condition =%d\n', ...
        datetime, feedbackType,condition);
fclose(logfile);
%}

switch feedbackType    
    %% Continuous PSC JONAS
        case 'bar_count'
        dispValue  = round(dispValue); %dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;
        switch condition
            case 1 % No activity - thermometer drawn but no real feedback displayed!
                % Text "HOLD"
                Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
                Screen('DrawText', P.Screen.wPtr, 'REPOS', ...
                    floor(P.Screen.w/2-P.Screen.h/7), ...
                    floor(P.Screen.h/2+1.5*P.Screen.h/10), P.Screen.white);
                % draw target bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
                    P.Screen.lw, [255 0 0]);
                % draw activity bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/2-dispValue), ...
                    floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]);
                % feedback value
                Screen('DrawText', P.Screen.wPtr, mat2str(dispValue), ...
                    P.Screen.w/2 - 3*P.Screen.w/30-100, ...
                    P.Screen.h/2 - P.Screen.h/50, [0 255 0]);
                % add onset time to output txt file
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(2), StimulusOnsetTime - P.TTLonsets);
            case 2 % Activity - feedback displayed
                % Text "MOVE"
                Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
                Screen('DrawText', P.Screen.wPtr, 'BOUGEZ', ...
                    floor(P.Screen.w/2-P.Screen.h/7), ...
                    floor(P.Screen.h/2+1.5*P.Screen.h/10), P.Screen.black);
                % draw target bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
                    P.Screen.lw, [255 0 0]);
                % draw activity bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/2-dispValue), ...
                    floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]);
                % feedback value
                Screen('DrawText', P.Screen.wPtr, mat2str(dispValue), ...
                    P.Screen.w/2 - 3*P.Screen.w/30-100, ...
                    P.Screen.h/2 - P.Screen.h/50, [0 255 0]);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(3), StimulusOnsetTime - P.TTLonsets);
            case 3 % General instructions
                Screen('TextSize', P.Screen.wPtr, textSizeInstr);
                line1 = 'Pour vous familiariser avec la technique de Neurofeedback,';
                line2 = '\n\n vous allez effectuer une tâche motrice.';
                DrawFormattedText(P.Screen.wPtr, [line1 line2], ...
                    'center', P.Screen.h * 0.45, P.Screen.black);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(1), StimulusOnsetTime - P.TTLonsets);
            case 4 % Instructions finger tapping
                Screen('TextSize', P.Screen.wPtr, textSizeInstr);
                line1 = 'Les instructions "repos" et bougez" vont être affichées alternativement.';
                line2 = '\n\n Lorsque "bougez" est affiché, bougez votre doigt de manière répétée';
                line3 = '\n\n et continue. Lorsque "repos" est affiché, ne bougez plus votre doigt.';
                DrawFormattedText(P.Screen.wPtr, [line1 line2 line3], ...
                    'center', P.Screen.h * 0.45, P.Screen.black);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(1), StimulusOnsetTime - P.TTLonsets);
            case 5 % Instructions - question
                Screen('TextSize', P.Screen.wPtr, textSizeInstr);
                line1 = 'Êtes-vous capable de voir une différence';
                line2 = '\n\n entre la phase "repos" et la phase "bougez"?';
                DrawFormattedText(P.Screen.wPtr, [line1 line2], ...
                    'center', P.Screen.h * 0.45, P.Screen.black);

                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(1), StimulusOnsetTime - P.TTLonsets);
            case 6 % Instructions imagination finger tapping A
                Screen('TextSize', P.Screen.wPtr, textSizeInstr);
                line1 = 'Ensuite, imaginez de faire le même mouvement que précédemment,';
                line2 = '\n\n sans réellement le faire. IMAGINEZ que vous tapez du doigt pendant';
                line3 = '\n\n "bougez" et IMAGINEZ de ne plus taper du doigt pendant "repos".';
                DrawFormattedText(P.Screen.wPtr, [line1 line2 line3], ...
                    'center', P.Screen.h * 0.45, P.Screen.black);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(1), StimulusOnsetTime - P.TTLonsets);
            case 7 % Instructions imagination finger tapping B
                Screen('TextSize', P.Screen.wPtr, textSizeInstr);
                line1 = 'En bougeant votre doigt, essayez vraiment d IMAGINER le ressenti du mouvement';
                line2 = '\n\n et pas uniquement d IMAGINER ce à quoi cela ressemble.';
                DrawFormattedText(P.Screen.wPtr, [line1 line2], ...
                    'center', P.Screen.h * 0.45, P.Screen.black);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(1), StimulusOnsetTime - P.TTLonsets);
            case 8 % End instructions
                Screen('TextSize', P.Screen.wPtr, textSizeInstr);
                line1 = 'Voyez-vous un changement d activité? Même en imaginant le mouvement?';
                line2 = '\n\n Vous avez maintenant une idée de comment fonctionne le neurofeedback.';
                DrawFormattedText(P.Screen.wPtr, [line1 line2], ...
                    'center', P.Screen.h * 0.45, P.Screen.black);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, P.Screen.vbl + P.Screen.ifi/2);
                fprintf(P.Motor_onset, '%s\t %d\t\n', P.condition_motor(1), StimulusOnsetTime - P.TTLonsets);
        end


    %{
    % CONTINUOUS PSC DEFAULT
case 'bar_count'
        dispValue  = dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;
        switch condition
            case 1 % Baseline
                % Text "COUNT"
                Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
                Screen('DrawText', P.Screen.wPtr, 'COUNT', ...
                    floor(P.Screen.w/2-P.Screen.h/4), ...
                    floor(P.Screen.h/2-P.Screen.h/10), instrColor);
            case 2 % Regualtion
                % Fixation Point
                Screen('FillOval', P.Screen.wPtr, [255 255 255], ...
                    [floor(P.Screen.w/2-P.Screen.w/200), ...
                    floor(P.Screen.h/2-P.Screen.w/200), ...
                    floor(P.Screen.w/2+P.Screen.w/200), ...
                    floor(P.Screen.h/2+P.Screen.w/200)]);
                % draw target bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
                    P.Screen.lw, [255 0 0]);
                % draw activity bar
                Screen('DrawLines', P.Screen.wPtr, ...
                    [floor(P.Screen.w/2-P.Screen.w/20), ...
                    floor(P.Screen.w/2+P.Screen.w/20); ...
                    floor(P.Screen.h/2-dispValue), ...
                    floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]);
        end
        P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
            P.Screen.vbl + P.Screen.ifi/2);
%}
    
    %% Continuous PSC with task block
%     case 'bar_count_task'
%         dispValue  = dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;
%         switch condition
%             case 1 % Baseline
%                 % Text "COUNT"
%                 Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
%                 Screen('DrawText', P.Screen.wPtr, 'COUNT', ...
%                     floor(P.Screen.w/2-P.Screen.h/4), ...
%                     floor(P.Screen.h/2-P.Screen.h/10), instrColor);
%                 
%                  P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
%                      P.Screen.vbl + P.Screen.ifi/2);
%                 
%             case 2 % Regualtion
%                 % Fixation Point
%                 Screen('FillOval', P.Screen.wPtr, [255 255 255], ...
%                     [floor(P.Screen.w/2-P.Screen.w/200), ...
%                     floor(P.Screen.h/2-P.Screen.w/200), ...
%                     floor(P.Screen.w/2+P.Screen.w/200), ...
%                     floor(P.Screen.h/2+P.Screen.w/200)]);
%                 % draw target bar
%                 Screen('DrawLines', P.Screen.wPtr, ...
%                     [floor(P.Screen.w/2-P.Screen.w/20), ...
%                     floor(P.Screen.w/2+P.Screen.w/20); ...
%                     floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
%                     P.Screen.lw, [255 0 0]); %red
%                 % draw activity bar
%                 Screen('DrawLines', P.Screen.wPtr, ...
%                     [floor(P.Screen.w/2-P.Screen.w/20), ... 
%                     floor(P.Screen.w/2+P.Screen.w/20); ...
%                     floor(P.Screen.h/2-dispValue), ...
%                     floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]); %green
%                 
%                     P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
%                         P.Screen.vbl + P.Screen.ifi/2);
%             case 3  
%                 % ptbTask sequence called seperetaly in python
%                 
%         end
        
    %% Intermittent SVM
    case 'value_fixation'
        dispValue  = round(dispValue); %dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;

        switch condition
            case 1  % Baseline
                t = P.randomizedTrials_neutral(P.neutral_image_idx);
                file = P.imgList_neutral_condition{t};
                image_name = fullfile(P.image_neutral_condition,file);
                image= imread(image_name);
                imageDisplay = Screen('MakeTexture', P.Screen.wPtr, image);

                Screen(P.Screen.wPtr,'FillRect',255/1.5);
                Screen('DrawTexture',P.Screen.wPtr, imageDisplay,[]);
                [StimulusOnsetTime] = Screen('Flip',P.Screen.wPtr);

                fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition_emo(2), StimulusOnsetTime - P.TTLonsets,...
                    convertCharsToStrings(image_name));

                P.neutral_image_idx = P.neutral_image_idx + 1;

            case 2 % WELCOME
                line1 = 'Bienvenue dans cette expérience';
                line2 = '\n \n Détendez-vous et essayez de ne pas bouger la tete';

                DrawFormattedText(P.Screen.wPtr, [line1 line2], ...
                    'center', P.Screen.h * 0.45);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);

                fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition_emo(1), StimulusOnsetTime - P.TTLonsets,...
                    'NA');

            case 3 % Baseline instructions
                line1 = 'Images neutres';
                %line2 = '\n \n Classez les images en fonction de leur type';
                %line3 = '\n\n\n Gauche = intérieur ; Droite = extérieur';

                DrawFormattedText(P.Screen.wPtr, [line1], ...
                    'center', P.Screen.h * 0.45);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
                
                fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition_emo(1), StimulusOnsetTime - P.TTLonsets,...
                    'NA');
                
            case 4 % Regulation instructions
                line1 = 'Images émotionnelles';
                line2 = '\n \n Essayez d"augmenter la jauge présentée en fin de bloc';

                DrawFormattedText(P.Screen.wPtr, [line1 line2], ...
                    'center', P.Screen.h * 0.45);
                [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr,P.Screen.vbl+P.Screen.ifi/2);
                
                 fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition_emo(1), StimulusOnsetTime - P.TTLonsets,...
                    'NA');
                
            case 5  % Regulation
                t = P.randomizedTrials_regulation(P.regulation_image_idx);
                file = P.imgList_regulation_condition{t};
                image_name = fullfile(P.image_regulation_condition,file);
                image= imread(image_name);
                imageDisplay = Screen('MakeTexture', P.Screen.wPtr, image);
                
                Screen(P.Screen.wPtr,'FillRect',255/1.5);
                Screen('DrawTexture',P.Screen.wPtr, imageDisplay,[]);
                [StimulusOnsetTime] = Screen('Flip',P.Screen.wPtr);

                fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition_emo(3), StimulusOnsetTime - P.TTLonsets,...
                    convertCharsToStrings(image_name));

                P.regulation_image_idx = P.regulation_image_idx + 1;
                
                
            case 6 % NF
                 % Fixation Point
                 Screen('FillOval', P.Screen.wPtr, [255 255 255], ...
                     [floor(P.Screen.w/2-P.Screen.w/200), ...
                     floor(P.Screen.h/2-P.Screen.w/200), ...
                     floor(P.Screen.w/2+P.Screen.w/200), ...
                     floor(P.Screen.h/2+P.Screen.w/200)]);

                 % draw target bar
                 Screen('DrawLines', P.Screen.wPtr, ...
                     [floor(P.Screen.w/2-P.Screen.w/20), ...
                     floor(P.Screen.w/2+P.Screen.w/20); ...
                     floor(P.Screen.h/10), floor(P.Screen.h/10)], ...
                     P.Screen.lw, [255 0 0]); %red

                 % draw activity bar
                 Screen('DrawLines', P.Screen.wPtr, ...
                     [floor(P.Screen.w/2-P.Screen.w/20), ...
                     floor(P.Screen.w/2+P.Screen.w/20); ...
                     floor(P.Screen.h/2-dispValue), ...
                     floor(P.Screen.h/2-dispValue)], P.Screen.lw, [0 255 0]) %green

                 % feedback value
                 Screen('DrawText', P.Screen.wPtr, mat2str(dispValue), ...
                     P.Screen.w/2 - P.Screen.w/30-100, ...
                     P.Screen.h/2 - P.Screen.h/50);

                 [P.Screen.vbl,StimulusOnsetTime] = Screen('Flip', P.Screen.wPtr, ...
                     P.Screen.vbl + P.Screen.ifi/2);

                  fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition(4), StimulusOnsetTime - P.TTLonsets,...
                     'NA');
                
                %transfert
%{
                drawCross(P.Screen.wPtr,P.Screen.w, P.Screen.h)
                %Screen(P.Screen.wPtr,'FillRect',255/1.5);
                [StimulusOnsetTime] = Screen('Flip',P.Screen.wPtr);
                
                fprintf(P.StimuliFile_NF, '%s\t %d\t %s\t\n', P.condition(5), StimulusOnsetTime - P.TTLonsets,...
                     'NA');
%}

        end
        
        
        %% intermittent PSC
%         indexSmiley = round(dispValue);
%         if indexSmiley == 0
%             indexSmiley = 1;
%         end
% 
%         switch condition
%             case 1  % Baseline
%                 t = P.randomizedTrials_neutral(P.neutral_image_idx);
%                 file = P.imgList_neutral_condition{t};
%                 img = imread(fullfile(P.image_neutral_condition,file));
%                 imageDisplay = Screen ('MakeTexture', P.Screen.wPtr,img);
% 
%                 showImagesAndFixationCross(P.Screen.wPtr, 255/1.5,...
%                     P.Screen.w,P.Screen.h,P.Screen.ifi, imageDisplay)
%                 P.neutral_image_idx = P.neutral_image_idx + 1;
%                 
%             case 2  % Regulation
%                 t = P.randomizedTrials_regulation(P.regulation_image_idx);
%                 file = P.imgList_regulation_condition{t};
%                 img = imread(fullfile(P.image_regulation_condition,file));
%                 imageDisplay = Screen ('MakeTexture', P.Screen.wPtr,img);
% 
%                 showImagesAndFixationCross(P.Screen.wPtr, 255/1.5,...
%                     P.Screen.w,P.Screen.h,P.Screen.ifi, imageDisplay)
%                 P.regulation_image_idx = P.regulation_image_idx + 1;
%                 
%             case 3 % NF
%                 % feedback value
%                 Screen('DrawText', P.Screen.wPtr, mat2str(dispValue), ...
%                     P.Screen.w/2 - P.Screen.w/30+0, ...
%                     P.Screen.h/2 - P.Screen.h/4, dispColor);
%                 % smiley
%                 Screen('DrawTexture', P.Screen.wPtr, ...
%                     Tex(indexSmiley), ...
%                     P.Screen.rectSm, P.Screen.dispRect+[0 0 0 0]);
%                 % display
%                 P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
%                     P.Screen.vbl + P.Screen.ifi/2);
%         end
         
    %% Trial-based DCM
    case 'DCM'
        nrP = P.nrP;
        nrN = P.nrN;
        imgPNr = P.imgPNr;
        imgNNr = P.imgNNr;
        switch condition           
            case 1 % Neutral textures
                % Define texture
                nrP = 0;
                nrN = nrN + 1;
                if (nrN == 1) || (nrN == 5) || (nrN == 9)
                    imgNNr = imgNNr + 1;
                    disp(['Neut Pict:' mat2str(imgNNr)]);
                end
                if nrN < 5
                    basImage = Tex.N(imgNNr);
                elseif (nrN > 4) && (nrN < 9)
                    basImage = Tex.N(imgNNr);
                elseif nrN > 8
                    basImage = Tex.N(imgNNr);
                end
                % Draw Texture
                Screen('DrawTexture', P.Screen.wPtr, basImage);
                P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl+P.Screen.ifi/2);

            case 2 % Positive textures
                % Define texture
                nrN = 0;
                nrP = nrP + 1;
                if (nrP == 1) || (nrP == 5) || (nrP == 9)
                    imgPNr = imgPNr + 1;
                    disp(['Posit Pict:' mat2str(imgPNr)]);
                end
                if nrP < 5
                    dispImage = Tex.P(imgPNr);
                elseif (nrP > 4) && (nrP < 9)
                    dispImage = Tex.P(imgPNr);
                elseif nrP > 8
                    dispImage = Tex.P(imgPNr);
                end
                % Draw Texture
                Screen('DrawTexture', P.Screen.wPtr, dispImage);
                P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl+P.Screen.ifi/2);

            case 3 % Rest epoch
                % Black screen case is called seaprately in Python to allow
                % using PTB Matlab Helper process for DCM model estimations

            case 4 % NF display
                nrP = 0;
                nrN = 0;
                % red if positive, blue if negative
                if dispValue >0
                    dispColor = [255, 0, 0];
                else
                    dispColor = [0, 0, 255];
                end
                % instruction reminder
                Screen('DrawText', P.Screen.wPtr, 'UP', ...
                    P.Screen.w/2 - P.Screen.w/15, ...
                    P.Screen.h/2 - P.Screen.w/8, [255, 0, 0]);
                % feedback value
                Screen('DrawText', P.Screen.wPtr, ...
                    ['(' mat2str(dispValue) ')'], ...
                    P.Screen.w/2 - P.Screen.w/7, ...
                    P.Screen.h/2 + P.Screen.w/200, dispColor);
                % monetary reward value
                Screen('DrawText', P.Screen.wPtr, ['+' Reward 'CHF'], ...
                    P.Screen.w/2 - P.Screen.w/7, ...
                    P.Screen.h/2 + P.Screen.w/7, dispColor);
                P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                    P.Screen.vbl + P.Screen.ifi/2);
                % basic flickering given TR
                if 1
                    pause(randi([600,800])/1000);
                    P.Screen.vbl=Screen('Flip', P.Screen.wPtr, ...
                        P.Screen.vbl + P.Screen.ifi/2);
                end
        end
        P.nrP = nrP;
        P.nrN = nrN;
        P.imgPNr = imgPNr;
        P.imgNNr = imgNNr;
end


%fclose(P.StimuliFile_NF);

% EventRecords for PTB
% Each event row for PTB is formatted as
% [t9, t10, displayTimeInstruction, displayTimeFeedback]
t = posixtime(datetime('now','TimeZone','local'));
tAbs = toc(tDispl);
if strcmp(displayStage, 'instruction')
    P.eventRecords(1, :) = repmat(iteration,1,4);
    P.eventRecords(iteration + 1, :) = zeros(1,4);
    P.eventRecords(iteration + 1, 1) = t;
    P.eventRecords(iteration + 1, 3) = tAbs;
elseif strcmp(displayStage, 'feedback')
    P.eventRecords(1, :) = repmat(iteration,1,4);
    P.eventRecords(iteration + 1, :) = zeros(1,4);
    P.eventRecords(iteration + 1, 2) = t;
    P.eventRecords(iteration + 1, 4) = tAbs;
end
recs = P.eventRecords;
save(P.eventRecordsPath, 'recs', '-ascii', '-double');

assignin('base', 'P', P);
