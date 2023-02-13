function drawError(P, color)
    Screen('FillRect', P.window, P.red)
    Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
        WaitSecs(0.2)
    Screen('FillRect', P.window, P.gray)
    Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
end
