% receive and synthesize note messages from midi in real time
function [start_time, duration, notes_vec, timestamp_vec, err_type] = single_block( ...
    num_notes, ...
    i_block, ...
    ear, ...
    hand, ...
    bMute, ...
    end_of_block_time,...
    start_of_run_tic)

    fprintf("Play!\n");

    if ~exist('bMute','var')
        % mute was not specified, default it to 0
        bMute = 0;
    end

    if ~exist('ear','var')
        % default to binaural playing
        ear = 'both';
    end

    timedOut = false;
    time_of_last_note = 0;
    duration_of_playing = 0;
    time_of_first_note = toc(start_of_run_tic);


    % initialize audio devices
    [osc, dev_writer] = initializeAudioDevices();
    s = osc();
    mute_waveform = zeros(length(s), 1);

    % initialize input vectors
    err_detect_vec = zeros(num_notes * 2, 1);
    notes_vec = zeros(num_notes * 2, 1);
    timestamp_vec = zeros(num_notes * 2, 1);

    try % a single block
        note_ctr = 1;
        while ((toc((start_of_run_tic))) <= end_of_block_time)
            timestamp_vec(note_ctr) = toc(start_of_run_tic);
            if note_ctr == 1
                time_of_first_note = toc(start_of_run_tic);
            end


            % psuedo code:
            % present black fixation
            % for numEventsPerBlock:
            %   wait interval
            %   present green fixation
            %   wait for button press
            %   after interval present black fixation again.
            %   verify it's the correct button
            %   play sound to correct ear
            %

        Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorGo, [xCenter yCenter], 2);
        Screen('Flip', window);
        rt=tic;
        pressed=0;
        while ~pressed
            [keyIsDown ,sec, keyCode] = KbCheck;
            if keyCode(r) || keyCode(b) % if correct button pressed for block
                log.RT(j,i)=toc(rt);
                log.cueTime(j,i)=toc(startRun);
                pressed=1;
                delay = tic;
                Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
                Screen('Flip', window);

                % busywait
                while toc(delay)<params.delayTime
                end
            else % incorrect buton pressed
                err=tic;
                DrawFormattedText(window, 'X' ,'center', 'center', [1,0,0]);
                Screen('Flip', window);
                while toc(err)<0.3
                end
            end
            end



                if bMute
                    dev_writer(mute_waveform);
                else
                    if strcmp(ear, 'R')
                        dev_writer([mute_waveform, osc()]);
                    elseif strcmp(ear, 'L')
                        dev_writer([osc(), mute_waveform()]);
                    elseif strcmp(ear, 'both')
                        dev_writer(osc());
                    end
                end

            end % while

            time_of_last_note = toc(start_of_run_tic);
            duration_of_playing = time_of_last_note - time_of_first_note;

        catch E
            clear sound

            % release objects
            release(osc);
            release(dev_writer);
            rethrow(E)
        end % try/catch

        clear sound

        % release objects
        release(osc);
        release(dev_writer);
        start_time = time_of_first_note;
        duration = duration_of_playing;

        % detect errors in block
        err = 0;
        err_type = "none";
        if strcmp(hand, 'R')
        elseif strcmp(hand, 'L')
        end

end
