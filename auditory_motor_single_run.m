
function auditory_motor_single_run(window, ...
                                   device, ...
                                   midi_table, ...
                                   data_table, ...
                                   conditions, ...
                                   num_blocks, ...
                                   num_notes, ...
                                   block_start_times, ...
                                   block_end_times, ...
                                   i_run)

      instruction = imread('auditory_only_instructions.jpg');
      display_image(instruction, window);
      shuffled_conditions = conditions(randperm(length(conditions)), :);

     % wait for a key press in order to continue
     % KbWait;
     % WaitSecs(0.5);
     waitForMRI()
     set_global_tic()
     block_start_times = block_start_times + get_global_tic()
     block_end_times = block_end_times + get_global_tic()

     for i_block = 1:num_blocks
          % get the start time of next block
         start_of_block_time = block_start_times(i_block);
         end_of_block_time = block_end_times(i_block);
         [ear, hand] = get_condition_for_block(shuffled_conditions, i_block)

         instruct_file = get_instruction_file_for_condition([ear hand]);
         instruction = imread(instruct_file);
         display_image(instruction, window);

         waitForTimeOrEsc(start_of_block_time, true, get_global_tic());

         instruction = imread('play.jpg');
         display_image(instruction, window);

         [start_time, duration, notes_vec, timestamp_vec] = playMIDI(device, num_notes, window, 1, i_block, 'both', false);

         data_table = updateTable(data_table, num_blocks, i_run, i_block, index_to_name(ear), index_to_name(hand), start_time, duration)

         midi_data_table = updateMidiTable(midi_data_table, num_blocks, i_run, i_block, notes_vec, timestamp_vec)
         waitForTimeOrEsc(end_of_block_time, true, get_global_tic());

     end
end
