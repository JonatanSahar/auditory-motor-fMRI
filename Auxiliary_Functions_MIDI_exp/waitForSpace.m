
function [] = waitForSpace()
    KbName('UnifyKeyNames');
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
