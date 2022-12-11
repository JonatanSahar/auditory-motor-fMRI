% receive and synthesize note messages from midi in real time
function [data_table] = playMIDI(midi_dev, train_len, i_block)
    midireceive(midi_dev);
    % initialize audio devices
    [osc, dev_writer] = initializeAudioDevices();
    % initialize input vectors
    notes_vec = zeros(train_len * 2, 1);
    timestamp_vec = zeros(train_len * 2, 1);
 
    % receive midi input for train_len
   note_ctr = 1;
    while note_ctr <= train_len 
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
                if i_block ~= 0 && msg.Note ~= 0 %not familiarization phase
                    notes_vec(note_ctr * 2 - 1) = msg.Note;
                    timestamp_vec(note_ctr * 2 - 1) = msg.Timestamp;
                end
                
            elseif isNoteOff(msg) 
                if msg.Note == msg.Note
                    osc.Amplitude = 0;
                   
                     % update data table with note pressed and timestamp
                    if i_block ~= 0 && msg.Note ~= 0 %not familiarization phase
                        notes_vec(note_ctr * 2) = msg.Note;
                        timestamp_vec(note_ctr * 2) = msg.Timestamp;
                    end
                    if msg.Note ~= 0 
                        note_ctr = note_ctr + 1;
                    end
                end
            end
        end
       
        % play audio signal
        dev_writer(osc()); 
    end

    % release objects
    release(osc);
    release(dev_writer);
end


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
