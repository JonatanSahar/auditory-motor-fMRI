function playGeneratedSequence(ear)
% ear must be: 'L' or 'R, or 'both
    start = tic;
    [osc, dev_writer] = initializeAudioDevices();
    IPI = 0.45;
    note_duration = 0.3;
    num_repeats = 2;
    time_between_repeats = 0.3;
    mute_waveform = audioOscillator('sine', 'Amplitude', 0);
    load('seq_mat.mat', 'seq_mat')
    WaitSecs(0.3);
    num_notes_played = 0;
    for t = 1 : num_repeats
        seq_indices = 1 : length(seq_mat);
        % in the first run of the sequence create an extra dummy note
        % in the begining and set its volume to 0
        if t == 1
            seq_indices = [1 seq_indices];
        end
        for i_msg = seq_indices
            curr_msg = seq_mat(i_msg);
            if isNoteOn(curr_msg)
                osc.Frequency = note2Freq(curr_msg.Note);
                osc.Amplitude = curr_msg.Velocity/127;
                % keep playing note for note_duration
                note_timing = tic;
                sine = audioOscillator('sine',44100/512);
                tone =  wavetableSynthesizer(sine(),osc.Frequency,'Amplitude', 1);
                max_amplitude = 0.7;
                accelaration = 0.8;

                gain_factor = 1;
                if t == 1 && num_notes_played < 1
                    num_notes_played = num_notes_played + 1;
                    gain_factor = 0;
                end

                while toc(note_timing) < note_duration
                        if strcmp(ear, 'R')
                            dev_writer([mute_waveform(), tone() * gain_factor]);
                        elseif strcmp(ear, 'L')
                            dev_writer([tone() * gain_factor, mute_waveform()]);
                        elseif strcmp(ear, 'both')
                            dev_writer(tone() * gain_factor);
                        end
                end
%                 pause between notes
            elseif isNoteOff(curr_msg)
                osc.Amplitude = 0;
                pause(IPI - note_duration);
            end

        end
        WaitSecs(time_between_repeats);
    end
    release(osc);
    release(dev_writer);
    toc(start);
end
