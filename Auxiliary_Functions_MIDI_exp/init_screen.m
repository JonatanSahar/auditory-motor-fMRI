function [window, rect] = init_screen(bSmall)
    Screen('Preference', 'SkipSyncTests', 2);
    if bSmall
        % uncomment in MRI computer
        init_pos_x = 20
        % init_pos_x = -2000
        init_pos_y = 10

        size_x = 1200;
        size_y = 700;
        pos_x = init_pos_x + size_x;
        pos_y = init_pos_y + size_y;
    [window, rect] = Screen('openwindow',1,[120, 120, 120], [init_pos_x, init_pos_y, pos_x, pos_y]);
    else
    [window, rect] = Screen('openwindow',2,[120, 120, 120]);
    end
end
