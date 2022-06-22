% receive and synthesize note messages from midi in real time
function [start_time, duration] = processAndPlaybackMIDI(midi_dev, num_notes, window, i_run, i_block, ear, bMute)

    if ~exist('mute','var')
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
    
 
    % % display black screen
    % Screen('FillRect', window, [0, 0, 0])
    % Screen('Flip', window);
    % Screen('TextSize', window ,74);
    % Screen('DrawText',window, 'Play', (960), (540), [255, 255, 255]);
    % Screen('Flip', window);

    % activate metronome
    % [y,Fs] = audioread('25 BPM.wav');
    % y = y * 100;
    % y1 = [y(:,1), zeros(length(y),1)];
    % y2 = [zeros(length(y),1), y(:,1)];

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
                    timestamp_vec(note_ctr * 2 - 1) = msg.Timestamp;
                end

                % end
            elseif isNoteOff(msg)
                if msg.Note == msg.Note
                    osc.Amplitude = 0;
                   
                     % update data table with note pressed and timestamp
                    if i_block ~= 0 && msg.Note ~= 0 % not familiarization phase
                        notes_vec(note_ctr * 2) = msg.Note;
                        timestamp_vec(note_ctr * 2) = msg.Timestamp;
                    end
                    if msg.Note ~= 0
                        if note_ctr == 1
                            time_of_first_note = toc(get_global_tic);
                        end
                        if note_ctr == num_notes
                            time_of_last_note = toc(get_global_tic);
                            duration_of_playing = time_of_last_note - time_of_first_note;
                        end
                        note_ctr = note_ctr + 1;
                    end
                end
            end
        end
        
        % play audio signal
        mute_waveform = audioOscillator('sine', 'Amplitude', 0);
        if ~bMute
            if ear == 'Right'
                dev_writer([osc(), mute_waveform()]);
            elseif ear == 'Left'
                dev_writer([mute_waveform(), osc()]);
            end
        end

    end
     clear sound
     
    % release objects
    release(osc);
    release(dev_writer);
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
