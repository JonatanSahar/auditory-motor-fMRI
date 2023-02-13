function [table, shuffled_conditions] = single_run(P, table)
    % get the ear for this run - each run has audio to a constant ear, with hands changing between blocks
    base_path = fullfile(pwd, 'output_data');
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
        [blockP.ear, blockP.hand] = get_condition_for_block(P.conditions, 1);
        run_instruction = imread(sprintf('audiomotor_%s_ear.JPG', blockP.ear));
        % P.num_blocks = 4;
        blockP.bMute = true;

    case 'audiomotor'
        temp_filename = "temp" + "(" + P.run_type + ")" + ".mat";
        [blockP.ear, blockP.hand] = get_condition_for_block(P.conditions, 1);
        run_instruction = imread(sprintf('audiomotor_%s_ear.JPG', blockP.ear));
        blockP.bMute = true;
    end

        temp_filename = fullfile(base_path, temp_filename);
        display_image(run_instruction, P.window);
        shuffled_conditions = P.conditions(randperm(length(P.conditions)), :);

        try
        waitForMRI()
        err_counter = 0;

        P.start_of_run_tic = tic;
        % wait before the first block
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

            blockP.err.MISSED_CUE =  0;
            blockP.err.WRONG_RESPONSE = 0;

            blockP.start_time = toc(P.start_of_run_tic);
            % get the correct image for the run instruction
            if contains(P.run_type, 'motor')
                instruction = imread(sprintf('%s.JPG', blockP.hand));
            else
                instruction = imread(sprintf('%s.JPG', blockP.ear));
            end

            display_image(instruction, P.window);
            waitForTimeOrEsc(start_of_block_time, true, P.start_of_run_tic);

            drawFixation(P, P.fixationColorGo)

            % start the actual run
            if contains(P.run_type, 'motor')
                % for the motor localizer, and the audiomotor runs
                single_block(P, blockP);
                blockP.duration = toc(P.start_of_run_tic);
                table = updateTable(P, blockP, table);

            else % not contains(P.run_type, 'motor')
                % for the auditory localizer
                playGeneratedSequence(blockP.ear);
                blockP.duration = toc(P.start_of_run_tic);
                table = updateTable(P, blockP, table);

            end
            


            % wait for remainder of time in block if needed.
            waitForTimeOrEsc(blockP.end_of_block_time, true, P.start_of_run_tic);

            % get the start time of next block, including the "false block" at the end, for the last fixation after the last block.
            instruction_time = P.instruction_display_times(block_num + 1);
            drawFixation(P, P.fixationColorRest)
            waitForTimeOrEsc(instruction_time, true, P.start_of_run_tic);

        end

            if err_counter > 0
                fprintf("*** This run contained %d playing errors ***\n", err_counter)
            end
            
            table = table;
            save(temp_filename, "table")

            break_img = imread('break.JPG');
            display_image(break_img, P.window);
    catch E
        rethrow(E)
        msgText = getReport(E,'basic');
        fprintf("Caught exception: %s\n", msgText)
        % ListenChar()
        end % try-catch block
        % ListenChar()

end % function
