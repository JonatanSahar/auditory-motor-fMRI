
function changeScreenBG(P, bgColor)

    if P.bShowDisplay
        Screen('FillRect', P.window, bgColor)
        Screen('Flip', P.window);
    end

    if P.bShowSmallDisplay
        Screen('FillRect', P.small_window, bgColor)
        Screen('Flip', P.small_window);
    end

