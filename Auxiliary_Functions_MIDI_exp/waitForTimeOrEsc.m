function waitForTimeOrEsc(timeToWait, bAbsoluteTime, startTic)
% This function operates in two modes:
% If only the time interaval to wait is given - it waits for the specified time.
% If bAbsoluteTime is specified, it waits for the remainig duration between startTic and the specified time.
%
    errID = 'myException:ESC';
    msg = 'ESC called';
    e = MException(errID,msg);
    if ~exist('bAbsoluteTime','var') || bAbsoluteTime ~= true
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
            if keyCode(KbName('ESCAPE'))
                Screen('CloseAll');                
                throw(e);
            end
        end
    end
end

