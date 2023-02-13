function drawFixation(P, color)

            Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
end
