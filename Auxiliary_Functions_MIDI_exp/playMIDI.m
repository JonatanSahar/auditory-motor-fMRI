% receive and synthesize note messages from midi in real time
function [start_time, duration, notes_vec, timestamp_vec] = playMIDI( ...
                                            midi_dev,...
                                            num_notes, ...
                                            window, ...
                                            i_run, ...
                                            i_block, ...
                                            ear, ...
                                            bMute)


if ~exist('bMute','var')
    % mute was not specified, default it to 0
    bMute = 0;
end

if ~exist('ear','var')
    % default to binaural playing
    ear = 'both';
end

midireceive(midi_dev);

% initialize audio devices
[osc, dev_writer] = intializeAudioDevices();
% initialize input vectors
notes_vec = zeros(num_notes * 2, 1);
timestamp_vec = zeros(num_notes * 2, 1);


% receive midi input for num_notes
note_ctr = 1;
while note_ctr <= num_notes
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
            
            % end
        elseif isNoteOff(msg)
            if msg.Note == msg.Note
                osc.Amplitude = 0;
                
                % update data table with note pressed and timestamp
                if i_block ~= 0 && msg.Note ~= 0 %not familiarization phase
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
    
     % play audio signal
     mute_waveform = audioOscillator('sine', 'Amplitude', 0);
        if bMute
            dev_writer(mute_waveform());
        else
            if strcmp(ear, 'R')
                dev_writer([osc(), mute_waveform()]);
            elseif strcmp(ear, 'L')
                dev_writer([mute_waveform(), osc()]);
            elseif strcmp(ear, 'both')
                dev_writer(osc());
            end
        end
    
end

time_of_last_note = toc(get_global_tic);
duration_of_playing = time_of_last_note - time_of_first_note;

clear sound

% release objects
release(osc);
release(dev_writer);
start_time = time_of_first_note;
duration = duration_of_playing;
end

% convert left hand notes to be similar to right hand's
% convert right hand notes to be similar to left hand's
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
