function waitForMRI()
    t_pressed = false;
    RestrictKeysForKbCheck([KbName('ESCAPE'), KbName('t')]);
    fprintf("waiting for next Tr cue from MRI...\n")
    while t_pressed == false
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(KbName('t'))
            t_pressed = true;
            fprintf("got t!\n")
        end
        if keyCode(KbName('ESCAPE'))
            return
        end
    end
    RestrictKeysForKbCheck([KbName('ESCAPE')]);
    %RestrictKeysForKbCheck(previousKeys);
end
