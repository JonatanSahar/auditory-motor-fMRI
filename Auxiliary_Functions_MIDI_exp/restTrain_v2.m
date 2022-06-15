% display white screen for 20 seconds
function train_table = restTrain_v2(rest_len, window, device, train_len, ...
    train_table, num_blocks, block_num, win_hight, win_width)
    rest_timing = tic;
    % return to white screen
    Screen('FillRect', window, [255, 255, 255] );
    Screen('Flip', window);
    WaitSecs(11);
    Screen('TextSize', window ,74);
    if block_num < num_blocks
        Screen('DrawText',window, 'Get Ready',(800),(540), [0, 0, 0]);
        Screen('Flip', window);
        pause(1);
    else
        block_num = num_blocks;
    end
    pause(0.5);
    time_point = toc(rest_timing);
    while time_point <= rest_len
        %press 'p' to pause experiment
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if keyIsDown
            key_pressed = find(keyCode);
            if strcmp('p', KbName(key_pressed))
                [train_table] = pause_experiment(device, train_len, ...
                    window, train_table, num_blocks, rest_len, ...
                    seq_mat, block_num, win_hight, win_width);
            end
        end
        time_point = toc(rest_timing);
    end 
end