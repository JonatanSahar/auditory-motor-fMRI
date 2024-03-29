
function data_table = motor_localizer(window, ...
                         device, ...
                         data_table, ...
                         conditions, ...
                         num_blocks, ...
                         num_notes, ...
                                      instruction_display_times, ...
                                      block_start_times, ...
                         block_end_times)

      instruction = imread('motor_localizer.JPG');
      display_image(instruction, window);

     i_run = 1; % one localizer run
     shuffled_conditions = conditions(randperm(length(conditions)), :);

     % wait for a key press in order to continue
     % KbWait;
     % WaitSecs(0.5);
     waitForMRI()
     start_tic = set_global_tic();

     for i_block = 1:num_blocks
          % get the start time of next block
         instruction_time = instruction_display_times(i_block);
         start_of_block_time = block_start_times(i_block);
         end_of_block_time = block_end_times(i_block);
         [ear, hand] = get_condition_for_block(shuffled_conditions, i_block);

         instruct_file = 'fixation.JPG'
         instruction = imread(instruct_file);
         display_image(instruction, window);
         waitForTimeOrEsc(instruction_time, true, start_tic);

         instruct_file = get_instruction_file_for_condition([ear hand]);
         instruction = imread(instruct_file);
         display_image(instruction, window);
         waitForTimeOrEsc(start_of_block_time, true, start_tic);

         instruction = imread('start.JPG');
         display_image(instruction, window);

         [start_time, duration] = playMIDI(device, num_notes, i_block, 'both', true);
         data_table = updateTable(data_table, num_blocks, i_run, i_block, ear, hand, start_time, duration);

         waitForTimeOrEsc(end_of_block_time, true, start_tic);        
         
     end
end
