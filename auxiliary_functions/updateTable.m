% update data table with block number, notes pressed and timestamps
function table = updateTable(P, blockP, table)
    curr_row = blockP.block_num;
    % curr_row = (i_run - 1) * num_blocks + i_block;

    table.run_num(curr_row) = P.run_num;
    table.block_num(curr_row) = blockP.block_num;
    table.start_time(curr_row) = blockP.start_of_block_time;
    table.play_duration(curr_row) = blockP.duration;
    table.end_time(curr_row) = blockP.start_of_block_time + blockP.duration;
    table.static_end_time(curr_row) = blockP.end_of_block_time;
    table.ear(curr_row) = blockP.ear;
    table.hand(curr_row) = blockP.hand;
    table.TOO_MANY_EVENTS(curr_row) = blockP.err.TOO_MANY_EVENTS;
    table.WRONG_RESPONSE(curr_row) = blockP.err.WRONG_RESPONSE;
    table.INCOMPLETE(curr_row) = blockP.err.INCOMPLETE;
    table.had_error(curr_row) = blockP.err.INCOMPLETE || blockP.err.WRONG_RESPONSE || blockP.err.TOO_MANY_EVENTS;
    table.weight(curr_row) = 1;
end
