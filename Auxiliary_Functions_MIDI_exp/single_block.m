% receive and synthesize note messages from midi in real time
function err_type = single_block(p, blockP)
    fprintf("Play!\n");
    err_type = 0;
    return

    if ~exist('bMute','var')
        % mute was not specified, default it to 0
        bMute = 0;
    end

    if ~exist('ear','var')
        % default to binaural playing
        ear = 'both';
    end



    % psuedo code:
    % present black fixation
    % for numEventsPerBlock:
    %   wait interval
    %   present green fixation
    %   wait for button press
    %   after interval present black fixation again.
    %   verify it's the correct button
    %   play sound to correct ear
    %
    try % a single block
        noteCount = 1;
        blockP.actualStartOfBlockTime = toc(P.start_of_run_tic);
        while ((toc((P.run_start_tic))) <= blockP.end_of_block_time)
            drawFixation(P, P.fixationColorGo);
            lastStimTic = tic;
            pressed=0;

            % busywait for button press, counting the RT
            while ~pressed && toc(lastStimTic) < P.InterPressInterval
                [keyIsDown ,sec, keyCode] = KbCheck;
                if correctKEyPressed(keyCode)
                    P.log.RT(blockP.block_num, noteCount) = toc(lastStimTic);
                    P.log.cueTimes(blockP.block_num, noteCount) = toc(P.startRun);
                    pressed = true;
                    delay = tic;
                    drawFixation(P, P.fixationColorRest);

                % incorrect buton pressed - flash an X and wait for press
                else
                    err = true;
                    DrawFormattedText(P.window, 'X' ,'center', 'center', [1,0,0]);
                    Screen('Flip', P.window);
                    WaitSecs(0.1)
                    drawFixation(P, P.fixationColorGo);
                end
            end
            % busywait till the next press is due..
            while toc(lastStimTic)<P.InterPressInterval
            end
        end
    end



    if bMute
        dev_writer(mute_waveform);
    else
        if strcmp(ear, 'R')
            dev_writer([mute_waveform, osc()]);
        elseif strcmp(ear, 'L')
            dev_writer([osc(), mute_waveform()]);
        elseif strcmp(ear, 'both')
            dev_writer(osc());
        end
    end

end % while

time_of_last_note = toc(start_of_run_tic);
duration_of_playing = time_of_last_note - time_of_first_note;

        catch E
            clear sound

            % release objects
            release(osc);
            release(dev_writer);
            rethrow(E)
        end % try/catch

        clear sound

        % release objects
        release(osc);
        release(dev_writer);
        start_time = time_of_first_note;
        duration = duration_of_playing;

        % detect errors in block
        err = 0;
        err_type = "none";
        if strcmp(hand, 'R')
        elseif strcmp(hand, 'L')
        end

end

function correctKEyPressed(hand, keyCodeArr)
    return (keyCode(r) && isequal(P.hand, 'R'))  || (keyCode(b) && isequal(P.hand, 'L'))
end

function drawFixation(P, color)

            Screen('DrawLines', P.window, P.fixationCoords, P.lineWidthFixation, color, [P.xCenter P.yCenter], 2);
            Screen('Flip', P.window);
end
