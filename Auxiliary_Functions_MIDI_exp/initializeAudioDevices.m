% initialize oscilator and audio device writer
function [osc, dev_writer] = initializeAudioDevices()
      osc = audioOscillator('sine', 'Amplitude', 0);
      dev_writer = audioDeviceWriter;
      dev_writer.SupportVariableSizeInput = true;
      dev_writer.BufferSize = 64; % small buffer keeps MIDI latency low
end
