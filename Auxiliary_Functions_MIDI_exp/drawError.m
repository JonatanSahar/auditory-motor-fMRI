function drawError(P, color)

    if P.bShowDisplay
    Screen('FillRect', P.window, P.red)
    Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
        WaitSecs(0.4)
    Screen('FillRect', P.window, P.gray)
    Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
    end

    if P.bShowSmallDisplay
    Screen('FillRect', P.small_window, P.red)
    Screen('DrawLines', P.small_window, P.fixationCoords, P.lineWidthFixation, color, [P.small_xCenter P.small_yCenter], 2);
            Screen('Flip', P.small_window);
        WaitSecs(0.4)
    Screen('FillRect', P.small_window, P.gray)
    Screen('DrawLines', P.small_window, P.fixationCoords, P.lineWidthFixation, color, [P.small_xCenter P.small_yCenter], 2);
            Screen('Flip', P.small_window);
    end
end
