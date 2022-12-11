% In case something went wrong during the block, press P during rest phase
% (while playing the seq). In order to repeat the last block or continue...
function [train_table] = pauseExperiment(device, train_len, ...
    window, train_table, num_blocks, rest_len, seq_mat, block_num)
    % show options slide (repeat or continue)
    instruct4 = imread('instruction4.jpg');
    TexturePointer = Screen('MakeTexture',window, instruct4);
    clear instruct4;
    Screen('DrawTexture',window, TexturePointer);
    Screen('Flip', window);
    % repeat or continue
    key_pressed = 'a';
    while ~ strcmp(KbName(key_pressed), 'c') && ~ strcmp(KbName(key_pressed), 'r')
        [keyIsDown, ~, keyCode] = KbCheck(-1);
        if keyIsDown
            key_pressed = find(keyCode);
            if strcmp('r', KbName(key_pressed)) %repeat previous block
                train_table = play_midi(device, ...
                    train_len, window, train_table, num_blocks + 10);
                train_table = rest(rest_len, window, ...
                    seq_mat, device, train_len, train_table, num_blocks, ...
                    block_num, win_hight, win_width);
            end
        end
    end
end