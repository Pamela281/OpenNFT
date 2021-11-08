function displayFeedback(displayData)
% Function to display feedbacks using PTB functions
%
% input:
% displayData - input data structure
%
% Note, synchronization issues are simplified, e.g. sync tests are skipped.
% End-user is advised to configure the use of PTB on their own workstation
% and justify more advanced configuration for PTB.
%__________________________________________________________________________
% Copyright (C) 2016-2021 OpenNFT.org
%
% Written by Yury Koush, Artem Nikonorov

tDispl = tic;

P = evalin('base', 'P');
Tex = evalin('base', 'Tex');

% Note, don't split cell structure in 2 lines with '...'.
fieldNames = {'feedbackType', 'condition', 'dispValue', 'Reward', 'displayStage','displayBlankScreen', 'iteration'};
defaultFields = {'', 0, 0, '', '', '', 0};
% disp(displayData)
eval(varsFromStruct(displayData, fieldNames, defaultFields))

if ~strcmp(feedbackType, 'DCM')
    dispColor = [255, 255, 255];
    instrColor = [155, 150, 150];
end

switch feedbackType    
    %% Continuous PSC
    case 'bar_count'
        dispValue  = dispValue*(floor(P.Screen.h/2) - floor(P.Screen.h/10))/100;
        switch condition
            case 1 % No activity - thermometer drawn but no feedback displayed
                % Text "HOLD"
                Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
                Screen('DrawText', P.Screen.wPtr, 'HOLD', ...
                    floor(P.Screen.w/2-P.Screen.h/7), ...
                    floor(P.Screen.h/2+1.5*P.Screen.h/10), [200 200 200]);
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
            case 2 % Activity
                % Text "MOVE"
                Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
                Screen('DrawText', P.Screen.wPtr, 'MOVE', ...
                    floor(P.Screen.w/2-P.Screen.h/7), ...
                    floor(P.Screen.h/2+1.5*P.Screen.h/10), [200 200 200]);
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
%               case 3 % General instructions
%                 % Text "HOLD"
%                 Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
%                 Screen('DrawText', P.Screen.wPtr, 'HOLD', ...
%                     floor(P.Screen.w/2-P.Screen.h/7), ...
%                     floor(P.Screen.h/2+1.5*P.Screen.h/10), [200 200 200]);
%               case 4 % Instructions to perform actual movement
%                 % Text "HOLD"
%                 Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
%                 Screen('DrawText', P.Screen.wPtr, 'HOLD', ...
%                     floor(P.Screen.w/2-P.Screen.h/7), ...
%                     floor(P.Screen.h/2+1.5*P.Screen.h/10), [200 200 200]);
                % instrText = 'First, please move your right forefinger up and down.';
%                 Screen('TextSize', P.Screen.wPtr , P.Screen.h/10);
%                 Screen('DrawText', P.Screen.wPtr, 'hello', ...
%                     floor(P.Screen.w/2-P.Screen.h/7), ...
%                     floor(P.Screen.h/2+1.5*P.Screen.h/10), [200 200 200]);
%             case 5 % Instructions to only imagine performing the movement
%             case 6 % End instructions
        end
        P.Screen.vbl = Screen('Flip', P.Screen.wPtr, ...
            P.Screen.vbl + P.Screen.ifi/2);
end

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
