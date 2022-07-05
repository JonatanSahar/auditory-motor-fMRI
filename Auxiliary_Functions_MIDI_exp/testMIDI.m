% receive and synthesize note messages from midi in real time
function testMIDI(midi_dev, train_len)
midireceive(midi_dev);
% initialize audio devices
[osc, dev_writer] = intializeAudioDevices();
% initialize input vectors

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
            
        elseif isNoteOff(msg)
            if msg.Note == msg.Note
                osc.Amplitude = 0;
                note_ctr = note_ctr + 1;
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
