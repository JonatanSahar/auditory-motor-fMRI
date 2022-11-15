function [window, rect] = init_screen(bSmall)
    Screen('Preference', 'SkipSyncTests', 2);
    if bSmall
        init_pos_x = 2000
        init_pos_y = 10
        size_x = 1200;
        size_y = 700;
        pos_x = init_pos_x + size_x;
        pos_y = init_pos_y + size_y;
    [window, rect] = Screen('openwindow',1,[0, 0, 0], [init_pos_x, init_pos_y, pos_x, pos_y]);
    else
    % [window, rect] = Screen('openwindow',1,[0, 0, 0], [20 10 1300 700]);
    [window, rect] = Screen('openwindow',1,[0, 0, 0]);
    end
end
