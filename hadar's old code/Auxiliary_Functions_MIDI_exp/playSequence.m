% play pre-training sequence
function playSequence(seq_mat, IPI)
    [osc, dev_writer] = intializeAudioDevices();
    note_duration = 0.15;

    % loop sequence (messages) matrix
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
        dev_writer(osc());
    end
    % release audio devices $$$$$$$$$ necessary???
    release(osc);
    release(dev_writer);
end