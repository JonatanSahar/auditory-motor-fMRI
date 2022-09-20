% receive and synthesize note messages from midi in real time
function [start_time, duration, notes_vec, timestamp_vec] = playMIDI( ...
    midi_dev,...
    num_notes, ...
    i_block, ...
    ear, ...
    bMute, ...
    end_of_block_time)


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
midireceive(midi_dev);

% initialize audio devices
[osc, dev_writer] = initializeAudioDevices();
s = osc();
mute_waveform = zeros(length(s), 1);

% initialize input vectors
notes_vec = zeros(num_notes * 2, 1);
timestamp_vec = zeros(num_notes * 2, 1);

try
%     receive midi input for num_notes
    note_ctr = 1;
    while note_ctr <= num_notes
        if((toc(get_global_tic())) >= end_of_block_time)
            timedOut = true;
            fprintf('************\nTime exceeded!\n************\n')
            throw(MException('Yonatan:time exceeded','time exceeded'));
        end
        msgs = midireceive(midi_dev);
        for i = 1:numel(msgs)
            msg = msgs(i);
            if isNoteOn(msg) % if note pressed
                % convert left hand notes to be similar to right hand's
                msg.Note = convertHand(msg.Note);
                % synthesize an audio signal
                osc.Frequency = note2Freq(msg.Note);
                osc.Amplitude = msg.Velocity/127;
                
                % update data table with note pressed and timestamp
                if i_block ~= 0 && msg.Note ~= 0 % not familiarization phase
                    notes_vec(note_ctr * 2 - 1) = msg.Note;
                    timestamp_vec(note_ctr * 2 - 1) = toc(get_global_tic); %msg.Timestamp;
                end
                
            elseif isNoteOff(msg)
                if msg.Note == msg.Note
                    osc.Amplitude = 0;
                    if i_block ~= 0 && msg.Note ~= 0 % not familiarization phase
                        notes_vec(note_ctr * 2) = msg.Note;
                        timestamp_vec(note_ctr * 2) = toc(get_global_tic); %msg.Timestamp;
                    end
                    if msg.Note ~= 0
                        if note_ctr == 1
                            time_of_first_note = toc(get_global_tic);
                        end
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
    
end

time_of_last_note = toc(get_global_tic);
duration_of_playing = time_of_last_note - time_of_first_note;

catch
end

clear sound

% release objects
release(osc);
release(dev_writer);
start_time = time_of_first_note;
duration = duration_of_playing;
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
