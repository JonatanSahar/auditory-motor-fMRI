function [table, shuffled_conditions, outP] = single_run(P, table)
    % init the log arrays for all the blocks in this run
% TODO: transpose the log matrics
    outP.log.cueTimes = nan(2 * P.num_events_per_block, P.num_blocks);
    outP.log.pressTimes = nan(2 * P.num_events_per_block, P.num_blocks);
    outP.log.errors = strings(2 * P.num_events_per_block, P.num_blocks);

    outP.duration = 0;

    switch P.run_type
      case 'motor_loc'
        temp_filename = "temp" + "(" + P.run_type + ")" + ".mat";
        run_instruction = imread('motor_localizer.JPG');
        blockP.bMute = true;

      case 'auditory_loc'
        temp_filename = "temp" + "(" + P.run_type + ")" + ".mat";
        run_instruction = imread('auditory_localizer.JPG');

      case 'audiomotor_short'
        temp_filename = "temp" + "(" + P.run_type + ")" + ".mat";
        [blockP.ear, blockP.hand] = ...
            get_condition_for_block(P.conditions, 1);
        run_instruction = ...
            imread(sprintf('audiomotor_%s_ear.JPG', blockP.ear));
        blockP.bMute = false;

      case 'audiomotor'
        temp_filename = "temp" + "(" + P.run_type + ")" + ".mat";
        [blockP.ear, blockP.hand] = ...
            get_condition_for_block(P.conditions, 1);
        run_instruction = ...
            imread(sprintf('audiomotor_%s_ear.JPG', blockP.ear));
        blockP.bMute = false;
    end

    temp_filename = fullfile(P.output_dir, temp_filename);
    display_image(P, run_instruction);
    shuffled_conditions = ...
        P.conditions(randperm(length(P.conditions)), :);

    try
        waitForMRI()
        err_counter = 0;

        P.start_of_run_tic = tic;
        instruction_time = P.instruction_display_times(1);
        [blockP.ear, blockP.hand] = get_condition_for_block(shuffled_conditions, 1);

        drawFixation(P, P.fixationColorRest)
        % wait for signal wash-out befor first stimulus
        waitForTimeOrEsc(instruction_time, true, P.start_of_run_tic);
        for block_num = 1:P.num_blocks
            blockP.block_num = block_num;
            start_of_block_time = P.block_start_times(block_num);
            blockP.end_of_block_time = P.block_end_times(block_num);
            [blockP.ear, blockP.hand] = get_condition_for_block(shuffled_conditions, block_num);

            blockP.err.WRONG_RESPONSE = 0;
            blockP.err.TOO_MANY_EVENTS = 0;
            blockP.err.INCOMPLETE = 0;
            
            blockP.start_of_block_time = P.block_start_times(block_num)
            % get the correct image for the run instruction
            if contains(P.run_type, 'motor')
                instruction = imread(sprintf('%s.JPG', blockP.hand));
            else
                instruction = imread(sprintf('%s.JPG', blockP.ear));
            end

            display_image(P, instruction);
            waitForTimeOrEsc(start_of_block_time, true, P.start_of_run_tic);

            blockP.start_of_block_actual = toc(P.start_of_run_tic)
            blockP.start_of_block_tic = tic;
            drawFixation(P, P.fixationColorRest)

            % start the actual run
            if contains(P.run_type, 'motor')

                blockOutP = single_block_self_paced(P, blockP);

                blockP.duration = blockOutP.duration; % toc(blockP.start_of_block_tic);
                blockP.err = blockOutP.err;
                table = updateTable(P, blockP, table);
                outP.log.pressTimes(1:size(blockOutP.log.pressTimes,2), blockP.block_num) = blockOutP.log.pressTimes;
                outP.log.errors(1:size(blockOutP.log.errors,2), blockP.block_num) = blockOutP.log.errors;


            else % not contains(P.run_type, 'motor')
                 % for the auditory localizer
                blockOutP = single_block_auditory(P, blockP);
                blockP.duration = toc(blockP.start_of_block_tic);
                table = updateTable(P, blockP, table);
            end


            % wait for remainder of time in block if needed.
            % TODO this is prob. unneccesary - it's the loop conditon in single_block.
            drawFixation(P, P.fixationColorRest)
            waitForTimeOrEsc(blockP.end_of_block_time, true, P.start_of_run_tic);

            % get the start time of next block, including the
            % "false block" at the end, for the last fixation after
            % the last block.
            instruction_time = P.instruction_display_times(block_num + 1);
            waitForTimeOrEsc(instruction_time, true, P.start_of_run_tic);
            err_counter = ...
                err_counter + blockP.err.WRONG_RESPONSE + blockP.err.TOO_MANY_EVENTS + blockP.err.INCOMPLETE;
        end

        if err_counter > 0
            fprintf("*** This run contained %d playing errors ***\n", err_counter)
        end

        table = table;
        save(temp_filename, "table")

        break_img = imread('break.JPG');
        display_image(P, break_img);
    catch E
        rethrow(E)
        msgText = getReport(E,'basic');
        fprintf("Caught exception: %s\n", msgText)
        % ListenChar()
    end % try-catch block
        % ListenChar()

end % function
