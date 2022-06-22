function waitForTimeOrEsc(timeToWait, bAbsoluteTime, startTic)
    errID = 'myException:ESC';
    msg = 'ESC called';
    e = MException(errID,msg);
    if ~exist('bAbsoluteTime','var')
        startTic = tic;
    % else fprintf("time left in run %f secs\n", timeToWait)
    end
    % repeat until a valid key is pressed or we time out
    timedOut = false;
    while ~timedOut
        % check if a key is pressed
        % only keys specified in activeKeys are considered valid
        if((toc(startTic)) >= timeToWait), timedOut = true; % fprintf("time passed %f secs\n", (toc(startTic)));
        else
            [ keyIsDown, keyTime, keyCode ] = KbCheck;
            if keyCode(KbName('ESCAPE')), throw(e); end
        end
    end
end

function waitForMRI()
    t_pressed = false;
    DisableKeysForKbCheck([]);
    fprintf("waiting for next Tr cue from MRI...\n")
    while t_pressed == false
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(KbName('t'))
            t_pressed = true;
            fprintf("got t!\n")
        end
        if keyCode(KbName('ESCAPE'))
            Screen('CloseAll');
            clear all
            return
        end
    end
    DisableKeysForKbCheck(KbName('t'));
end

function [] = waitForSpace()
    spacePressed = 0;
    errID = 'myException:ESC';
    msg = 'ESC called';
    e = MException(errID,msg);
    while ~spacePressed
        % check if a key is pressed
        % only keys specified in activeKeys are considered valid
        [ keyIsDown, keyTime, keyCode ] = KbCheck;
        if keyCode(KbName('SPACE')), spacePressed = 1;
        end
        % if keyCode(KbName('ESCAPE')), throw(e);
        % end
    end
end
