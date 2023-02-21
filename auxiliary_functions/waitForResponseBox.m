function key = waitForResponseBox()
    key = 'none';
    [ keyIsDown, keyTime, keyCode ] = KbCheck;
    if keyCode(KbName('ESCAPE'))
        throw(MException('MATLAB:badMojo','ESC called'));
    end
    if keyCode(KbName('r'))
        key = 'r';
    elseif keyCode(KbName('b'));
        key = 'b';
    end
end
