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
