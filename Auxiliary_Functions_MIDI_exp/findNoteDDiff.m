% calculate median note duration of a block
function Note_d_diff = findNoteDDiff(block_num, data_table, note_duration)
    % extract curent blocks rows
    block_indices = data_table.block == block_num;
    block_table = data_table(block_indices, :);

    % seperate odd and even rows
    on_times = block_table.time_stamp(1 : 2 : end);
    off_times = block_table.time_stamp(2 : 2 : end);
    % calculate inter press interval difference
    median_note_d = median(off_times - on_times);
    Note_d_diff = (median_note_d - note_duration) * 1000;
end