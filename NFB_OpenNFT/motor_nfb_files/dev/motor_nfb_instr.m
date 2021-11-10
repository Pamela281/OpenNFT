% Script to display instructions before starting motor neurofeedback
%% General set up
% Clear the workspace and the screen
close all;
clear;
sca

% Set variables
% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Select the external screen if it is present, else revert to the native
% screen
screenNumber = max(screens);

% Define black, white and grey
black = BlackIndex(screenNumber);
white = WhiteIndex(screenNumber);
grey = white / 2;

% Open an on screen window and color it grey
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Set the blend function for the screen
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

%% 1st intro routine
instrText = 'Welcome to the experiment!';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, instrText, 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(2)

%% 2nd intro routine
line1 = 'Before starting with the main experiment,';
line2 = '\n\n you are going to perform a small motor task,';
line3 = '\n\n to familiarize yourself with the feedback method.';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, [line1 line2 line3], 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(10)

%% 3rd intro routine
line1 = 'First, you will be instructed to perform';
line2 = '\n\n an actual movement at certain timepoints.';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, [line1 line2], 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(5)

%% 4th intro routine
line1 = 'The goal is that you see how the activity';
line2 = '\n\n of your brain area is displayed,';
line3 = '\n\n and that you get a feeling for the delay of the feedback.';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, [line1 line2 line3], 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(10)

%% 5th intro routine
instrText = 'Please pay attention to how the feedback bar changes.';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, instrText, 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(5)

%% 6th intro routine
line1 = 'Please perform the actual/imagined movement throughout';
line2 = '\n\n for as long as the "move" instruction is displayed.';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, [line1 line2], 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(5)

%% 1st task routine: actual movement
%% 5th intro routine
instrText = 'First, please move your right forefinger up and down.';
% Draw text in the middle of the screen in Courier in white
Screen('TextSize', window, 80);
% Screen('TextFont', window, 'Courier');
DrawFormattedText(window, instrText, 'center', 'center', white);
% Flip to the screen
Screen('Flip', window);
% give time to read
WaitSecs(5)

%% End instructions
% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo
% KbStrokeWait;

% Clear the screen
sca;