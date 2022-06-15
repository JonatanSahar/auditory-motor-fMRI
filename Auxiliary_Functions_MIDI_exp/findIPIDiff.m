% calculate mean inter-press-interval of a block
function IPI_diff = findIPIDiff(block_num, data_table, IPI)
    % extract curent blocks rows
    block_indices = data_table.block == block_num;
    block_table = data_table(block_indices, :);

    % seperate odd and even rows
    on_times2 = block_table.time_stamp( 3 : 2 : end - 1);
    on_times = block_table.time_stamp(1 : 2 : end- 3);
    % calculate inter press interval difference
    median_IPI = median(on_times2 - on_times);
    IPI_diff = (median_IPI - IPI) * 1000;
end