function [window, rect] = init_screen()
    [window, rect] = Screen('openwindow',1,[0, 0, 0], [200 10 1500 700]);
%     [window, rect] = Screen('openwindow',1,[0, 0, 0], [10 10 300 300]);
end
