%%
clc; clear;
%%
data = xlsread(fullfile('C:\Users\User\Desktop\Hadar\Auditory_Ex\midi_data\sub_131\131_LH-LE_post_test_1.xls'));

%% Parameters
nTestBlock = 4; %number of blocks
blockSize = 80; %block range
sequence = [79, 74, 79, 77, 76, 74, 72, 76]; %first sequence
seq_len = length(sequence);
trial_per_block = 5; %number of sequences in block
block_len = seq_len * trial_per_block;
blockInd = 1 : blockSize : size(data, 1); %block index
t_stamp = data(:, 2, end);
notes = data(1 : 2 : end, 3);
b_t_stamp_test = reshape(t_stamp, [], 4 );
b_notes_test = reshape(notes, [], 4 );

%% check errors for each block
b_correct = zeros(1, nTestBlock);
b_notes_test(b_notes_test == 0) = NaN;
mean_std_IPI = zeros(2, nTestBlock);
b_IPI = NaN(5, nTestBlock);


for i_col = 1 : (nTestBlock)
    check_seq = strfind(b_notes_test(:, i_col)', sequence);
    seq_num = length(check_seq);
    b_correct(i_col) = seq_num;
    
    for i_seq = 1 : (seq_num)
        on_times2 = b_t_stamp_test(check_seq(i_seq) + 2 : 2 : check_seq(i_seq) + seq_len * 2 - 2, i_col);
        on_times1 = b_t_stamp_test(check_seq(i_seq) : 2 : check_seq(i_seq) + seq_len * 2 - 4, i_col);
        b_IPI((i_seq  - 1) * (seq_len - 1) + 1 : i_seq * (seq_len - 1), i_col) = (on_times2 - on_times1);
        mean_std_IPI(1, i_col) = mean(on_times2 - on_times1);
        mean_std_IPI(2, i_col) = std(on_times2 - on_times1);
        %mean_std_IPI = mean_std_IPI';
    end
         
 
end


        
      