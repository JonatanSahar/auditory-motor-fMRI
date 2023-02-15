function keyCode = waitForTimeOrEsc(timeToWait, bCountFromTic, startTic)
% This function operates in two modes:
% If only the time interaval to wait is given - it waits for the specified time.
% If bCountFromTic is specified, it waits for the remainig duration between startTic and the specified time.
%
    if ~exist('bCountFromTic','var') || bCountFromTic ~= true
        startTic = tic;
    end
    keyCode = zeros(1, 256);
    timedOut = false;

    if((toc(startTic)) >= timeToWait)
                fprintf('out of time before timer started!\n');
    end
    while ~timedOut
        if((toc(startTic)) >= timeToWait), timedOut = true;
            [ keyIsDown, keyTime, keyCode ] = KbCheck;
            if keyCode(KbName('ESCAPE'))
                throw(MException('MATLAB:badMojo','ESC called'));
            end
        end
    end
end

