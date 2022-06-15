clc; clear;
% create midi messages matrix
time_stamp = 0;
IPI = 0.3;
Note_d = 0.15;
notes = [79, 74, 79, 77, 76, 74, 72, 76, 79, 74, 79, 77, 76, 74, 72, 76,...
    79, 74, 79, 77, 76, 74, 72, 76, 79, 74, 79, 77, 76, 74, 72, 76, 79, 74, 79, 77, 76, 74, 72, 76];
seq_mat = midimsg('NoteOn',1 ,72 ,127 ,0);
i_note = 1;
for i_row = 1 : numel(notes) * 2
    if mod(i_row, 2) == 0
        time_stamp = time_stamp + IPI - Note_d;
        seq_mat(i_row, :) = midimsg('NoteOff', 1, notes(i_note), 0, time_stamp);
        i_note = i_note + 1;
    else
        time_stamp = time_stamp + Note_d;
        seq_mat(i_row, :) = midimsg('NoteOn', 1, notes(i_note), 127, time_stamp);
    end
end
save(fullfile(pwd, 'seq_mat'), 'seq_mat');




