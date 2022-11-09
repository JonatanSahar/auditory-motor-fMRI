function [window, rect] = init_screen()
    Screen('Preference', 'SkipSyncTests', 2);
    [window, rect] = Screen('openwindow',0,[0, 0, 0], [20 10 1300 700]);
    % [window, rect] = Screen('openwindow',1,[0, 0, 0]);
end
