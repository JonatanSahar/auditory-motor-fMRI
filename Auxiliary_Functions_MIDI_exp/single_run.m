function [data_table, midi_data_table] = single_run(window, ...
                                                    device, ...
                                                    midi_data_table, ...
                                                    data_table, ...
                                                    conditions, ...
                                                    num_notes, ...
                                                    num_blocks, ...
                                                    instruction_display_times, ...
                                                    block_start_times, ...
                                                    block_end_times, ...
                                                    i_run,...
                                                    run_type)
% get the ear for this run - each run has audio to a constant ear, with hands changing between blocks
switch run_type
  case 'motor_loc'
    run_instruction = imread('motor_localizer.JPG');
    block_instruction = imread('start.JPG');
  case 'auditory_loc'
    run_instruction = imread('auditory_localizer.JPG');
    block_instruction = imread('listen.JPG');
  case 'audiomotor'
    [ear, hand] = get_condition_for_block(conditions, 1)
    run_instruction = imread(sprintf('audiomotor_%s_ear.JPG', ear));
    block_instruction = imread('play.JPG');
end

    display_image(run_instruction, window);
    shuffled_conditions = conditions(randperm(length(conditions)), :);

    % wait for a key press in order to continue
    % KbWait;
    % WaitSecs(0.5);
    waitForMRI()
    RestrictKeysForKbCheck(['ESCAPE'])
    start_tic = tic;
    err_counter = 0;

    for i_block = 1:num_blocks
        % get the start time of next block
        instruction_time = instruction_display_times(i_block);
        start_of_block_time = block_start_times(i_block);
        end_of_block_time = block_end_times(i_block);
        [ear, hand] = get_condition_for_block(shuffled_conditions, i_block);

         fixation = imread('fixation.JPG');
         display_image(fixation, window);
         waitForTimeOrEsc(instruction_time, true, start_tic);

    [ear, hand] = get_condition_for_block(conditions, i_block)

    if contains(run_type, 'motor')
        instruction = imread(sprintf('%s.JPG', hand));
    else
        instruction = imread(sprintf('%s.JPG', ear));
    end

        display_image(instruction, window);
        waitForTimeOrEsc(start_of_block_time, true, start_tic);
        display_image(block_instruction, window);

        if contains(run_type, 'motor') % for the motor localizer, and the audiomotor runs
            [start_time, duration, notes_vec, timestamp_vec, err] = playMIDI(device, ...
                                                                        num_notes, ...
                                                                        i_block, ...
                                                                        ear, ...
                                                                        hand, ...
                                                                        false, ...
                                                                        end_of_block_time, ...
                                                                        start_tic);
            if err
                err_counter = err_counter + 1;
            end
    else
         start_time = toc(start_tic);
         playSequence(ear);
         duration = toc(start_tic);
    end


    RestrictKeysForKbCheck([])

        data_table = updateTable(data_table, num_blocks, i_run, i_block, ear, hand, start_time, duration);

        if strcmp(run_type, 'audiomotor')
            midi_data_table = updateMidiTable(midi_data_table, i_run, i_block, notes_vec, timestamp_vec);
        end
        waitForTimeOrEsc(end_of_block_time, true, start_tic);

    end
    % wait for one last inter-block rest time (=8 sec) after the last block
        instruction_time = instruction_display_times(num_blocks + 1);
         fixation = imread('fixation.JPG');
         display_image(fixation, window);
         waitForTimeOrEsc(instruction_time, true, start_tic);

         if err_counter > 0
             fprintf("*** This run contained %d playing errors ***\n", err_counter)
         end
end
