function drawCross(w,dispW,dispH, barColor)
    barLength = 32; %in pixels 16
    barWidth = 4; % in pixels 2
    %barColor = 1; % number from 0 (black) to 1 (white)
    Screen ('FillRect', w, barColor,[(dispW -barLength)/2 (dispH-barWidth)/2 (dispW + barLength)/2 (dispH + barWidth)/2]);
    Screen ('FillRect', w, barColor,[(dispW - barWidth)/2 (dispH-barLength)/2 (dispW + barWidth)/2 (dispH + barLength)/2]);
end
