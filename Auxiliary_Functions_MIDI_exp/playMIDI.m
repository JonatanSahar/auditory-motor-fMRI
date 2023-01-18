% receive and synthesize note messages from midi in real time
function [start_time, duration, notes_vec, timestamp_vec, err_type] = playMIDI( ...
    midi_dev,...
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
ERROR_CODE = 999;
time_of_last_note = ERROR_CODE;
duration_of_playing = ERROR_CODE;
time_of_first_note = ERROR_CODE;

correct_notes_R  = repmat([72, 74, 79, 77, 76, 74], 1, 2);
correct_notes_L  = repmat([55, 53, 48, 50, 52, 53], 1, 2);

% correct_notes_R  = repmat([79, 77, 76, 74, 72], 1, 2);
% correct_notes_L  = repmat([48, 50, 52, 53, 55], 1, 2);
midireceive(midi_dev);

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
    while (note_ctr <= num_notes) && ((toc((start_of_run_tic))) <= end_of_block_time)
        msgs = midireceive(midi_dev);
        for i = 1:numel(msgs)
            msg = msgs(i);
            if isNoteOn(msg) % if note pressed
                % convert left hand notes to be similar to right hand's
                err_detect_vec(note_ctr) = msg.Note;
                msg.Note = convertHand(msg.Note);
                % synthesize an audio signal
                osc.Frequency = note2Freq(msg.Note);
                osc.Amplitude = msg.Velocity/127;
                % update data table with note pressed and timestamp
                if i_block ~= 0 && msg.Note ~= 0 %not familiarization phase
                    notes_vec(note_ctr * 2 - 1) = msg.Note;
                    timestamp_vec(note_ctr * 2 - 1) = msg.Timestamp;
                    if note_ctr == 1
                        time_of_first_note = toc(start_of_run_tic);
                    end
                end

            elseif isNoteOff(msg)
                if msg.Note == msg.Note
                    osc.Amplitude = 0;

                     % update data table with note pressed and timestamp
                    if i_block ~= 0 && msg.Note ~= 0 %not familiarization phase
                        notes_vec(note_ctr * 2) = msg.Note;
                        timestamp_vec(note_ctr * 2 - 1) = toc(start_of_run_tic);
                    end
                    if msg.Note ~= 0
                        note_ctr = note_ctr + 1;
                    end
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
played_notes = nonzeros(err_detect_vec)';
err = 0;
err_type = "none";
if strcmp(hand, 'R')
    correct_notes = correct_notes_R;
    other_hand_notes = correct_notes_L;
elseif strcmp(hand, 'L')
    correct_notes = correct_notes_L;
    other_hand_notes = correct_notes_R;
end

if ~isequal(played_notes, correct_notes)
    err = 1;
    err_type = "err_wrong_notes";

    fprintf("**************\n");
    fprintf("WRONG NOTES PLAYED!\n")

    notes_from_other_hand = ismember(played_notes, other_hand_notes);
    if any(notes_from_other_hand)
        err_type = "err_wrong_hand";
        fprintf("notes played with wrong hand! \n")
    end
end

if err
    fprintf("Played notes: [")
    fprintf('%g ', played_notes);
    fprintf('] instead of [')
    fprintf('%g ', correct_notes);
    fprintf(']\n');
    fprintf("number of notes played: %d instead of %d \n",  ...
            numel(played_notes), numel(correct_notes))
    fprintf("**************\n\n");
else
    fprintf("*** All notes were played correctly :) ***\n\n")
    err_type = 'none';
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
