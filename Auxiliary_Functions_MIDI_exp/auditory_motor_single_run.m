function [data_table, midi_data_table] = auditory_motor_single_run(window, ...
                                                                   device, ...
                                                                   midi_data_table, ...
                                                                   data_table, ...
                                                                   conditions, ...
                                                                   num_notes, ...
                                                                   num_blocks, ...
                                                                   block_start_times, ...
                                                                   block_end_times, ...
                                                                   i_run)
% get the ear for this run - each run has audio to a constant ear, with hands changing between blocks
    (ear, hand) = conditions(1);
    if ear == "R"
        file = 'audiomotor_R_ear.JPG';
    else
        file = 'audiomotor_L_ear.JPG';
    end

    instruction = imread(file);
    display_image(instruction, window);
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
        [ear, hand] = get_condition_for_block(shuffled_conditions, i_block);

        instruct_file = get_instruction_file_for_condition([ear hand]);
        instruction = imread(instruct_file);
        display_image(instruction, window);

        waitForTimeOrEsc(start_of_block_time, true, get_global_tic());

        instruction = imread('play.JPG');
        display_image(instruction, window);

        % TODO: impose the lenght of the block inside playMIDI. Pass
        % end_of_block_time to it
        [start_time, duration, notes_vec, timestamp_vec] = playMIDI(device, num_notes, i_block, ear, false, end_of_block_time);

        data_table = updateTable(data_table, num_blocks, i_run, i_block, ear, hand, start_time, duration)

        midi_data_table = updateMidiTable(midi_data_table, i_run, i_block, notes_vec, timestamp_vec)
        waitForTimeOrEsc(end_of_block_time, true, get_global_tic());

    end
end
