% play pre-training sequence
function playSequence(ear)
filename = "./audio_files/sequence.mp3"
[osc, dev_writer] = initializeAudioDevices();
[y, fs] = audioread(filename);
signal = y(:,1);
mute_waveform = zeros(length(signal), 1);
if strcmp(ear, 'R')
    dev_writer([mute_waveform(), signal]);
elseif strcmp(ear, 'L')
    dev_writer([signal, mute_waveform()]);
elseif strcmp(ear, 'both')
    dev_writer(signal);
end
    release(osc);
    release(dev_writer);
end
%     [osc, dev_writer] = initializeAudioDevices();
%     IPI = 0.9;
%     ear = 'both'
%     note_duration = 0.7;
%     num_repeats = 1;
%     time_between_repeats = 0.5;
%     loop sequence (messages) matrix
%     WaitSecs(0.3);
%     mute_waveform = audioOscillator('sine', 'Amplitude', 0);
%     for t = 1 : num_repeats
%         for i_msg = 1 : length(seq_mat)
%             curr_msg = seq_mat(i_msg);
%             each note has a NoteOn and a NoteOff messages
%             if isNoteOn(curr_msg)
%                 osc.Frequency = note2Freq(curr_msg.Note);
%                 osc.Amplitude = curr_msg.Velocity/127;
%                 keep playing note for note_duration
%                 note_timing = tic;
%                 sine = audioOscillator('sine',44100/512);
%                 tone =  wavetableSynthesizer(sine(),osc.Frequency,'Amplitude', 1);
%                 max_amplitude = 0.7;
%                 accelaration = 0.8;
%                 while toc(note_timing) < note_duration
%                     if toc(note_timing) <= 0.5 * note_duration
%                         gain_factor = min(max_amplitude, accelaration * toc(note_timing)/note_duration);
%                     elseif toc(note_timing) > 0.5 * note_duration
%                         gain_factor = min(max_amplitude, accelaration * (1 - toc(note_timing)/note_duration));
%                     else
%                         gain_factor = 1;
%                     end
%                     
%                     if strcmp(ear, 'R')
%                         dev_writer([mute_waveform(), tone() * gain_factor]);
%                     elseif strcmp(ear, 'L')
%                         dev_writer([tone() * gain_factor, mute_waveform()]);
%                     elseif strcmp(ear, 'both')
%                         dev_writer(tone() * gain_factor);
%                     end
%                 end
%                 pause between notes
%             elseif isNoteOff(curr_msg)
%                 osc.Amplitude = 0;
%                 pause(IPI - note_duration);
%             end
% 
%         end
%         WaitSecs(time_between_repeats);
%     end
%     release(osc);
%     release(dev_writer);
% end
% 
% 