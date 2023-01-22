
function display_image(image, window)
global bShowDisplay;
global bSmallDisplay;

if ~bShowDisplay
    return
end

if bSmallDisplay
    global small_window;
    Screen('Flip', small_window);
    TexturePointer = Screen('MakeTexture',small_window, image);
    Screen('DrawTexture',small_window, TexturePointer);
    Screen('Flip', small_window);
end

Screen('FillRect', window, [230, 230, 230])
Screen('Flip', window);
TexturePointer = Screen('MakeTexture',window, image);
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);


end
