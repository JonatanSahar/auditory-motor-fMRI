function drawFixation(P, color)

    if P.bShowDisplay
            Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
    end

    if P.bShowSmallDisplay
            Screen('DrawLines', P.small_window, P.fixationCoords, P.lineWidthFixation, color, [P.small_xCenter P.small_yCenter], 2);
            Screen('Flip', P.small_window);
    end
end
