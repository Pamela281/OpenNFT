function drawCross(w,dispW,dispH)
    barLength = 16; %in pixels
    barWidth = 2; % in pixels
    barColor = 0.5; % number from 0 (black) to 1 (white)
    Screen ('FillRect', w, barColor,[(dispW -barLength)/2 (dispH-barWidth)/2 (dispW + barLength)/2 (dispH + barWidth)/2]);
    Screen ('FillRect', w, barColor,[(dispW - barWidth)/2 (dispH-barLength)/2 (dispW + barWidth)/2 (dispH + barLength)/2]);
end
