% receive and synthesize note messages from midi in real time
function outP = single_block(P, blockP)
    
    start = tic;
    fprintf("Play!\n");
    err_type = 0;
    outP.err.WRONG_RESPONSE  = 0;
    outP.err.MISSED_CUE  = 0;

    try % a single block
        eventCount = 1;
        waitForTimeOrEsc(P.IPI, true, blockP.start_of_block_tic);
        while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
            drawFixation(P, P.fixationColorGo);
            P.lastStimTic = tic;
            outP.log.cueTimes(eventCount) = toc(P.start_of_run_tic);
            
            key = waitForResponseBox(P, P.fixationDisplayDuration)
            outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
            if key ~= 'none' & isCorrectKey(key, blockP.hand)
                playSound(P, blockP.ear, blockP.bMute)
                % WaitSecs(0.2);
                % drawFixation(P, P.fixationColorRest);
                outP.log.errors(eventCount) = "NONE";
            else
                % no buttons pressed
                if key == 'none'
                    outP.err.MISSED_CUE =  outP.err.MISSED_CUE + 1;
                    outP.log.errors(eventCount) = "MISSED_CUE";
                % incorrect buton pressed
                else
                    outP.err.WRONG_RESPONSE = outP.err.WRONG_RESPONSE + 1;
                    outP.log.errors(eventCount) = "WRONG_RESPONSE";
                end
                drawError(P, P.fixationColorRest); % flash a red background
                % drawFixation(P, P.fixationColorRest);
            end
            waitForTimeOrEsc(P.fixationDisplayDuration, true, P.lastStimTic);
            drawFixation(P, P.fixationColorRest);
            waitForTimeOrEsc(P.IPI, true, P.lastStimTic);
            eventCount = eventCount + 1;
        end
    catch E
        rethrow(E)
    end


