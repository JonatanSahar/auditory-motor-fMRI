% update data table with block number, notes pressed and timestamps
function data_table = updateTable(data_table, num_blocks, i_run, i_block, ear, hand, start_time, duration)
    curr_row = (i_run - 1) * num_blocks + i_block;
    
    data_table.run_num(curr_row) = i_run;
    data_table.block_num(curr_row) = i_block;
    data_table.start_time(curr_row) = start_time;
    data_table.play_duration(curr_row) = duration;
    data_table.ear(curr_row) = ear;
    data_table.hand(curr_row) = hand;
end
