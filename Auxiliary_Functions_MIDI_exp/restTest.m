% display white screen for 15 seconds
function restTest(rest_len, window)
    % display white screen
    rest_timing = tic;
    Screen('FillRect', window, [255, 255, 255] );
    Screen('Flip', window);
    WaitSecs(11);
    Screen('TextSize', window ,74);
    Screen('DrawText',window, 'Get Ready',(800),(540), [0, 0, 0]);
    Screen('Flip', window);
    pause(0.5);
    time_point = toc(rest_timing);
    while time_point <= rest_len
        time_point = toc(rest_timing);
    end 
end