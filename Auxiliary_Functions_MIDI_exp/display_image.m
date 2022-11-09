
function display_image(image, window)
    Screen('FillRect', window, [231, 230, 230])
    Screen('Flip', window);
    TexturePointer = Screen('MakeTexture',window, image);
    Screen('DrawTexture',window, TexturePointer);
    Screen('Flip', window);
end
