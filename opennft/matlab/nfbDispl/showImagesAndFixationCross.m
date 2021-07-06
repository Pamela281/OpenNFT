function showImagesAndFixationCross (w,backgroundColor, dispW,dispH,slack, imageDisplay)

    %TR = 2;

    % Show the images
    Screen(w,'FillRect',backgroundColor);
    Screen('DrawTexture',w, imageDisplay,[]);
    startTIme = Screen('Flip',w);
    % WaitSecs(2*TR);
    pause(1)

    %Show fixation cross
    fixationDuration = 1;
    drawCross(w,dispW,dispH);
    tFixation = Screen('Flip',w);

    %Blank ptbBlank
    Screen(w, 'FillRect', backgroundColor);
    Screen('Flip', w,tFixation + fixationDuration - slack, 0);
end

