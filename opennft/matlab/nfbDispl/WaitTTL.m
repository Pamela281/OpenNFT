function WaitTTL()

    keyWasPressed = false;

    while(keyWasPressed == false)
        [keyWasPressed,~,keyCode] = KbCheck;
        if keyCode (KbName('t')) ==1
            break
        end
    end
end