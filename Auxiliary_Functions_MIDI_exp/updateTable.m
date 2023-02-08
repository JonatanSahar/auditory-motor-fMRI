% update data table with block number, notes pressed and timestamps
function table = updateTable(P, blockP, table)
    curr_row = blockP.block_num;
    % curr_row = (i_run - 1) * num_blocks + i_block;

    table.run_num(curr_row) = P.run_num;
    table.block_num(curr_row) = blockP.block_num;
    table.start_time(curr_row) = blockP.start_time;
    table.play_duration(curr_row) = blockP.duration;
    table.ear(curr_row) = blockP.ear;
    table.hand(curr_row) = blockP.hand;
    table.error(curr_row) = blockP.err;
end
