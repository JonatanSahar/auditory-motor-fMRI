
function changeFixationColors(P, bgColor, fgcolor)

    if P.bShowDisplay
        Screen('FillRect', P.window, bgColor)
        Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, fgcolor, [P.xCenter P.yCenter], 2);
        Screen('Flip', P.window);
    end

    if P.bShowSmallDisplay
        Screen('FillRect', P.small_window, bgColor)
        Screen('DrawLines', P.small_window, P.fixationCoords, P.lineWidthFixation, fgcolor, [P.small_xCenter P.small_yCenter], 2);
        Screen('Flip', P.small_window);
    end
end
