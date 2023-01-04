% update data table with block number, notes pressed and timestamps
function midi_data_table = updateMidiTable(midi_data_table, i_run, i_block, notes_vec, timestamp_vec)
if i_run ~= 0
    
    update_len = length(notes_vec); % must always be 2 * sequence length
    for i_note = 1 : update_len
        curr_row = update_len * (i_block - 1) + i_note;
        % curr_row = update_len * (i_run - 1 + i_block - 1) + i_note;
        midi_data_table.run_num(curr_row) = i_run;
        midi_data_table.block_num(curr_row) = i_block;
        midi_data_table.time_stamp(curr_row) = timestamp_vec(i_note);
        midi_data_table.note(curr_row) = notes_vec(i_note);
        if mod(i_note, 2)
            midi_data_table.is_on(curr_row) = 1;
            if i_note > 1
                midi_data_table.ipi(curr_row) = ...
                    timestamp_vec(i_note) - timestamp_vec(i_note-1); %time diff between press and previous release
                
            end
        else
            midi_data_table.is_on(curr_row) = 0;
        end
    end
end
end
