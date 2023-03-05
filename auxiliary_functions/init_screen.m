function [window, xCenter, yCenter] = init_screen(P, size)
    Screen('Preference', 'SkipSyncTests', 2);
    switch size
      case 'small'
        init_pos_x = 20 % uncomment in magnet
%         init_pos_x = -1700 % uncomment at home
%         init_pos_x = 2000 
        init_pos_y = 10

        size_x = 1200;
        size_y = 700;
        pos_x = init_pos_x + size_x;
        pos_y = init_pos_y + size_y;
        [window, rect] = Screen('openwindow',0,[230, 230, 230],...
                            [init_pos_x, init_pos_y, pos_x, pos_y]);

      case 'fullscreen'
        [window, rect] = Screen('openwindow',2,[230, 230, 230]);
    end
    % Get the centre coordinate of the window in pixels
    [xCenter, yCenter] = RectCenter(rect);
    Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
end
