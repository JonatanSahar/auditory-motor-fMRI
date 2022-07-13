% play pre-training sequence
function playSequence(seq_mat, IPI, ear)
    [osc, dev_writer] = intializeAudioDevices();
    note_duration = 0.3;
    num_repeats = 2;
    time_between_repeats = 0.5;
    % loop sequence (messages) matrix
    WaitSecs(note_duration);
    for t = 1 : num_repeats
    for i_msg = 1 : length(seq_mat)
        curr_msg = seq_mat(i_msg);
        % each note has a NoteOn and a NoteOff messages
        if isNoteOn(curr_msg) 
            osc.Frequency = note2Freq(curr_msg.Note);
            osc.Amplitude = curr_msg.Velocity/127;
            % keep playing note for note_duration
            note_timing = tic;
            while toc(note_timing) < note_duration
                tone = osc();
                dev_writer(tone);
            end
        % pause between notes
        elseif isNoteOff(curr_msg)
            if curr_msg.Note == curr_msg.Note
                osc.Amplitude = 0;
            end
            pause(IPI - note_duration);
        end

        mute_waveform = audioOscillator('sine', 'Amplitude', 0);
        if strcmp(ear, 'R')
            dev_writer([osc(), mute_waveform()]);
        elseif strcmp(ear, 'L')
            dev_writer([mute_waveform(), osc()]);
        elseif strcmp(ear, 'both')
            dev_writer(osc());
        end

    end
    WaitSecs(time_between_repeats);
    end
    % release audio devices $$$$$$$$$ necessary???
    release(osc);
    release(dev_writer);
end
