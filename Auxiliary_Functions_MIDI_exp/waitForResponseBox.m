function key = waitForResponseBox(P, maxTimeToWait, bCountFromTic, startTic)
    key = 'none';
    fprintf("waiting for next Tr cue from MRI...\n")
    rPressed = 0;
    bPressed = 0;
    pressed = 0;
    timedOut = false;

    if ~exist('bCountFromTic','var') || bCountFromTic ~= true
        startTic = tic;

    while ~timedOut && ~pressed
        % check if a key is pressed
        % only keys specified in activeKeys are considered valid
        if((toc(startTic)) >= maxTimeToWait)
            timedOut = true;
        else
            [ keyIsDown, keyTime, keyCode ] = KbCheck;
            if keyCode(KbName('ESCAPE'))
                throw(MException('MATLAB:badMojo','ESC called'));
            end
            rPressed = keyCode(KbName('r'));
            bPressed = keyCode(KbName('b'));
            pressed = rPressed || bPressed;
        end
    end

    if rPressed
        key = 'r';
    elseif bPressed
        key = 'b';
    end
end
