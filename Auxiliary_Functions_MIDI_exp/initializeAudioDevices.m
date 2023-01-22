% initialize oscilator and audio device writer
function [osc, dev_writer] = initializeAudioDevices()
      osc = audioOscillator('sine', 'Amplitude', 0);
      dev_writer = audioDeviceWriter;
      dev_writer.SupportVariableSizeInput = true;
      % small buffer keeps MIDI latency low, too small and we get underrun
      % (=choppy sound)
      dev_writer.BufferSize = 128; 
end
