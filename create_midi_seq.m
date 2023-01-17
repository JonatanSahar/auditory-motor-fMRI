function seq_mat = create_midi_seq()
% create midi messages matrix
time_stamp = 0;
IPI = 0.3;
Note_duration = 0.15;
notes = [72, 74, 79, 77, 76, 74, 72];
% notes = [79, 77, 76, 74, 72];
seq_mat = midimsg('NoteOn',1 ,72 ,127 ,0);
i_note = 1;
for i_row = 1 : numel(notes) * 2
    if mod(i_row, 2) == 0
        time_stamp = time_stamp + IPI - Note_duration;
        seq_mat(i_row, :) = midimsg('NoteOff', 1, notes(i_note), 0, time_stamp);
        i_note = i_note + 1;
    else
        time_stamp = time_stamp + Note_duration;
        seq_mat(i_row, :) = midimsg('NoteOn', 1, notes(i_note), 127, time_stamp);
    end
end
save(fullfile(pwd, 'seq_mat'), 'seq_mat');

end
