% receive and synthesize note messages from midi in real time
function outP = single_block(P, blockP)
    fprintf("Play!\n");
    err_type = 0;
    outP.err.WRONG_RESPONSE  = 0;
    outP.err.MISSED_CUE  = 0;

    if ~exist('bMute','var')
        % mute was not specified, default it to 0
        bMute = 0;
    end

    if ~exist('ear','var')
        % default to binaural playing
        ear = 'both';
    end

    try % a single block
        eventCount = 1;
        while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
            drawFixation(P, P.fixationColorGo);
            P.lastStimTic = tic;
            outP.log.cueTimes(blockP.block_num, eventCount) = toc(P.start_of_run_tic);
            
            key = waitForResponseBox(P, P.fixationDisplayDuration)
            outP.log.pressTimes(blockP.block_num, eventCount) = toc(P.start_of_run_tic);
            if key ~= 'none' & isCorrectKey(key, blockP.hand)
                playSound(P, blockP.ear, false)
                % WaitSecs(0.2);
                % drawFixation(P, P.fixationColorRest);
                outP.log.errors(blockP.block_num, eventCount) = "NONE";
            else
                % no buttons pressed
                if key == 'none'
                    outP.err.MISSED_CUE =  outP.err.MISSED_CUE + 1;
                    outP.log.errors(blockP.block_num, eventCount) = "MISSED_CUE";
                % incorrect buton pressed
                else
                    outP.err.WRONG_RESPONSE = outP.err.WRONG_RESPONSE + 1;
                    outP.log.errors(blockP.block_num, eventCount) = "WRONG_RESPONSE";
                end
                drawError(P, P.fixationColorRest); % flash a red background
                % drawFixation(P, P.fixationColorRest);
            end
            waitForTimeOrEsc(P.fixationDisplayDuration, true, P.lastStimTic);
            drawFixation(P, P.fixationColorRest);
            waitForTimeOrEsc(P.interPressInterval, true, P.lastStimTic);
            eventCount = eventCount + 1;
        end
    catch E
        rethrow(E)
    end


