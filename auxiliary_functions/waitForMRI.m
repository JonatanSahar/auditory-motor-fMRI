function waitForMRI()
    t_pressed = false;
    fprintf("waiting for next Tr cue from MRI...\n")
    DisableKeysForKbCheck([]);
    while t_pressed == false
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(KbName('t'))
            t_pressed = true;
            fprintf("got t!\n")
            DisableKeysForKbCheck(KbName('t'));
            ListenChar(2) % enable listening for chars, but suppress output to console
        end
        if keyCode(KbName('ESCAPE'))
            ListenChar(1) % enable listening for chars and output to console
            return
        end
    end
end
