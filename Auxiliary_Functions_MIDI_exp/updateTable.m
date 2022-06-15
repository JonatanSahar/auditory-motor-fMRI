% update data table with block number, notes pressed and timestamps
function data_table = updateTable(data_table, i_block, notes_vec, timestamp_vec, train_len)
train_len=train_len*2;
for i_note = 1 : train_len
    curr_row = train_len * (i_block - 1) + i_note;
    data_table.block(curr_row) = i_block;
    data_table.time_stamp(curr_row) = timestamp_vec(i_note);
    data_table.note(curr_row) = notes_vec(i_note);
    if mod(i_note, 2)
        data_table.velocity(curr_row) = 127;
    else
        data_table.velocity(curr_row) = 0;
    end
end
end
