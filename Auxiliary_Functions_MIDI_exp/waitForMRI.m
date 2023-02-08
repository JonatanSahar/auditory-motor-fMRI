function waitForMRI()
    t_pressed = false;
    fprintf("waiting for next Tr cue from MRI...\n")
    while t_pressed == false
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(KbName('t'))
            t_pressed = true;
            fprintf("got t!\n")
            DisableKeysForKbCheck(KbName('t'));
        end
        if keyCode(KbName('ESCAPE'))
            return
        end
    end
end
