
function display_image(image, window)
    Screen('FillRect', window, [172, 172, 172])
    Screen('Flip', window);
    TexturePointer = Screen('MakeTexture',window, image);
    Screen('DrawTexture',window, TexturePointer);
    Screen('Flip', window);
end
