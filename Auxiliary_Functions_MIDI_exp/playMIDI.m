% receive and synthesize note messages from midi in real time
function [start_time, duration, notes_vec, timestamp_vec] = playMIDI( ...
    midi_dev,...
    num_notes, ...
    i_block, ...
    ear, ...
    hand, ...
    bMute, ...
    end_of_block_time,...
    start_of_run_tic)

caught = 0;
if ~exist('bMute','var')
    mute was not specified, default it to 0
    bMute = 0;
end     

if ~exist('ear','var')
    default to binaural playing
    ear = 'both';
end

timedOut = false;
ERROR_CODE = 999;
time_of_last_note = ERROR_CODE;
duration_of_playing = ERROR_CODE;
time_of_first_note = ERROR_CODE;
correct_notes_R  = repmat([79, 77, 76, 74, 72], 1, 2);
correct_notes_L  = repmat([48, 50, 52, 53, 55], 1, 2);
midireceive(midi_dev);

% initialize audio devices
[osc, dev_writer] = initializeAudioDevices();
s = osc();
mute_waveform = zeros(length(s), 1);

% initialize input vectors
err_detect_vec = zeros(num_notes * 2, 1);
notes_vec = zeros(num_notes * 2, 1);
timestamp_vec = zeros(num_notes * 2, 1);

try
    %     receive midi input for num_notes
    note_ctr = 1;
    while (note_ctr <= num_notes) && ((toc((start_of_run_tic))) <= end_of_block_time)
        % if((toc((start_of_run_tic))) >= end_of_block_time)
        %     fprintf('************\nTime exceeded!\n************\n')

        %     release(osc);
        %     release(dev_writer);

        %     throw(MException('MATLAB:badMojo','time exceeded'));
        % else
            [keyIsDown, keyTime, keyCode] = KbCheck;
            if keyCode(KbName('ESCAPE'))
                fprintf('************\nEscape called!\n************\n')
                throw(MException('MATLAB:badMojo','ESC called'));

            end
        % end

        msgs = midireceive(midi_dev);
        for i = 1:numel(msgs)
            msg = msgs(i);
            if isNoteOn(msg) % if note pressed
                % convert left hand notes to be similar to right hand's
                err_detect_vec(note_ctr) = msg.note;
                msg.Note = convertHand(msg.Note);
                % synthesize an audio signal
                osc.Frequency = note2Freq(msg.Note);
                osc.Amplitude = msg.Velocity/127;

                % update data table with note pressed and timestamp
                if i_block ~= 0 && msg.Note ~= 0 % not familiarization phase
                    notes_vec(note_ctr * 2 - 1) = msg.Note;
                    timestamp_vec(note_ctr * 2 - 1) = toc(start_of_run_tic); %msg.Timestamp;
                end

            elseif isNoteOff(msg)
                    osc.Amplitude = 0;
                    if i_block ~= 0 && msg.Note ~= 0 % not familiarization phase
                        notes_vec(note_ctr * 2) = msg.Note;
                        timestamp_vec(note_ctr * 2) = toc(start_of_run_tic); %msg.Timestamp;
                    end
                    if msg.Note ~= 0
                        if note_ctr == 1
                            time_of_first_note = toc(start_of_run_tic);
                        end
                        note_ctr = note_ctr + 1;
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

    if ((toc((start_of_run_tic))) <= end_of_block_time) % we didn't exceed the time
        time_of_last_note = toc(start_of_run_tic);
        duration_of_playing = time_of_last_note - time_of_first_note;
    end

catch E
    caught = 1;
    rethrow(E)
end % try/catch

clear sound

% release objects
release(osc);
release(dev_writer);
start_time = time_of_first_note;
duration = duration_of_playing;

% detect errors in block
played_notes = nonzeros(err_detect_vec)';
err = false;
err_type = "none";
if strcmp(hand, 'R')
    correct_notes = correct_notes_R;
elseif strcmp(hand, 'L')
    correct_notes = correct_notes_L;
end

if numel(played_notes) ~= numel(correct_notes)
    err = true;
    err_type = "err_num_notes";
    fprintf("*** WRONG NUMBER OF NOTES PLAYED: %d INSTEAD OF %d ***\n",  ...
            numel(played_notes), numel(correct_notes))

elseif played_notes ~= correct_notes
    err = true;
    err_type = "err_wrong_notes";

    fprintf("*** WRONG NOTES PLAYED! ***\n")

    other_hand_notes = ~ismember(played_notes, correct_notes)
    if any(other_hand_notes)
    err_type = "err_wrong_hand";
    fprintf("*** NOTES PLAYED with wrong hand! ***\n")
    end
end

if err
    % switch err_type
    %   case 'err_wrong_notes'
    %      error_message = imread('err_num_notes.JPG');
    %   case 'err_wrong_notes'
    %      error_message = imread('err_wrong_notes.JPG');
    %   case 'err_wrong_notes'
    %      error_message = imread('err_wrong_hand.JPG');
    % end
    %      display_image(error_message, window);
    %      waitForTimeOrEsc(instruction_time, true, start_tic);

    fprintf("*** Played notes: [")
    fprintf('%g ', played_notes);
    fprintf('] instead of [')
    fprintf('%g ', correct_notes);
    fprintf('] ***\n');
end


end

% convert left hand notes to be similar to right hand's
function note = convertHand(note)
switch note
    case 48
        note = 79;
    case 50
        note = 77;
    case 52
        note = 76;
    case 53
        note = 74;
    case 55
        note = 72;
end

end
