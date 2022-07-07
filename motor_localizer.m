
function motor_localizer(window, device, data_table, conditions, num_blocks, block_start_times, block_end_times)
      instruction = imread('motor_only_instructions.jpg');
      display_image(instruction, window);

     i_run = 1; % one localizer run
     shuffled_conditions = conditions(randperm(length(conditions)), :);

     % wait for a key press in order to continue
     % KbWait;
     % WaitSecs(0.5);
     waitForMRI()
     set_global_tic()
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

         [start_time, duration] = processAndPlaybackMIDI(device, num_notes, window, 1, i_block, 'both', true);
         data_table = updateTable(data_table, num_blocks, i_run, i_block, index_to_name(ear), index_to_name(hand), start_time, duration)

         waitForTimeOrEsc(end_of_block_time, true, get_global_tic());

     end
end
