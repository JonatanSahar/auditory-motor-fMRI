% receive and synthesize note messages from midi in real time
function [data_table] = playMIDI(midi_dev, train_len, window, data_table, i_block)
    midireceive(midi_dev);
    % initialize audio devices
    [osc, dev_writer] = intializeAudioDevices();
    % initialize input vectors
 
    display black screen
    Screen('FillRect', window, [0, 0, 0])
    Screen('Flip', window);
    Screen('TextSize', window ,74);
    Screen('DrawText',window, 'Play', (960), (540), [255, 255, 255]);
    Screen('Flip', window);
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
                        if note_ctr == 1
                            time_of_first_note = toc(get_global_tic);
                        end
                        if note_ctr == train_len
                            time_of_last_note = toc(get_global_tic);
                            duration_of_playing = time_of_last_note - time_of_first_note;
                        end
                        note_ctr = note_ctr + 1;
                    end
                end
            end
        end
       
        % play audio signal
        dev_writer(osc()); 
    end
   % update table from vectors between blocks
    if istable(data_table)
        data_table.block_num(i_block) = i_block;
        data_table.start_time(i_block) = time_of_first_note;
        data_table.play_duration(i_block) = time_of_first_note;
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
