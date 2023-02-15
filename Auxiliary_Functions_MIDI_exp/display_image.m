function display_image(P, image)
    if P.bShowSmallDisplay
        Screen('FillRect', P.small_window, [230, 230, 230])
        Screen('Flip', P.small_window);
        TexturePointer = Screen('MakeTexture',P.small_window, image);
        Screen('DrawTexture',P.small_window, TexturePointer);
        Screen('Flip', P.small_window);
    end

    if P.bShowDisplay
        Screen('FillRect', P.window, [230, 230, 230])
        Screen('Flip', P.window);
        TexturePointer = Screen('MakeTexture',P.window, image);
        Screen('DrawTexture',P.window, TexturePointer);
        Screen('Flip', P.window);
    end


end
