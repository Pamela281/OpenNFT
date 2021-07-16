function showImagesAndFixationCross (w,backgroundColor, dispW,dispH,slack, imageDisplay)

    %TR = 2;

    % Show the images
    Screen(w,'FillRect',backgroundColor);
    Screen('DrawTexture',w, imageDisplay,[]);
    Screen('Flip',w);
    %startTime = Screen('Flip',w);
    %imageduration = 2;
    %Screen('Flip',w,startTime + imageduration - slack, 0);
    % WaitSecs(2*TR);
    %pause(2)

    %Show fixation cross
%     fixationDuration = 1;
%     drawCross(w,dispW,dispH);
%     tFixation = Screen('Flip',w);
% 
%     %Blank ptbBlank
%     Screen(w, 'FillRect', backgroundColor);
%     Screen('Flip', w,tFixation + fixationDuration - slack, 0);
end

