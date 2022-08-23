function [window, rect] = init_screen()
    Screen('Preference', 'SkipSyncTests', 2);
    %[window, rect] = Screen('openwindow',0,[0, 0, 0], [200 10 1500 700]);
    [window, rect] = Screen('openwindow',1,[0, 0, 0], [20 10 220 500]);
end
