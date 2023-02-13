% receive and synthesize note messages from midi in real time
function single_block(P, blockP)
    fprintf("Play!\n");
    err_type = 0;

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
        blockP.actualStartOfBlockTime = toc(P.start_of_run_tic);
        while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
            drawFixation(P, P.fixationColorGo);
            P.lastStimTic = tic;
            P.log.cueTimes(blockP.block_num, eventCount) = toc(P.start_of_run_tic);
            
            key = waitForResponseBox(P, P.fixationDisplayDuration)
            P.log.pressTimes(blockP.block_num, eventCount) = toc(P.start_of_run_tic);
            if key ~= 'none' & isCorrectKey(key, blockP.hand)
                drawFixation(P, P.fixationColorRest);
                P.log.errors(blockP.block_num, eventCount) = "NONE";
                playSound(P, blockP.ear, false)
            else
                % no buttons pressed
                if key == 'none'
                    blockP.err.MISSED_CUE =  blockP.err.MISSED_CUE + 1;
                    P.log.errors(blockP.block_num, eventCount) = "MISSED_CUE";
                % incorrect buton pressed
                else
                    blockP.err.WRONG_RESPONSE = blockP.err.WRONG_RESPONSE + 1;
                    P.log.errors(blockP.block_num, eventCount) = "WRONG_RESPONSE";
                end
                drawError(P, P.fixationColorRest); % flash a red background
                drawFixation(P, P.fixationColorRest);
            end
            waitForTimeOrEsc(P.interPressInterval, true, P.lastStimTic);
            eventCount = eventCount + 1;
        end
    catch E
        rethrow E
    end


