function [window, rect] = init_screen()
    Screen('Preference', 'SkipSyncTests', 2);
    % [window, rect] = Screen('openwindow',0,[0, 0, 0], [200 10 1500 700]);
    [window, rect] = Screen('openwindow',0,[0, 0, 0], [200 10 500 500]);
end
