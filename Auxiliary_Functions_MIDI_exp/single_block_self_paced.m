% receive and synthesize note messages from midi in real time
function outP = single_block_self_paced(P, blockP)
start = tic;
fprintf("Play!\n");
err_type = 0;
outP.err.WRONG_RESPONSE  = 0;
outP.err.MISSED_CUE  = 0;
blockP.actual_start_of_block_II = toc(P.start_of_run_tic);
try % a single block
    eventCount = 1;
    waitForTimeOrEsc(P.IPI, true, blockP.start_of_block_tic);
    drawFixation(P, P.fixationColorGo);
    while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
        key = waitForResponseBox(P, P.fixationDisplayDuration);
        
        if isCorrectKey(key, blockP.hand) & (eventCount <= P.num_events_per_block)
            outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
            outP.log.cueTimes(eventCount) = toc(P.start_of_run_tic);
            
            playSound(P, blockP.ear, blockP.bMute)
            outP.log.errors(eventCount) = "NONE";
            if  eventCount == P.num_events_per_block
                drawError(P, P.green, P.fixationColorRest); % flash a green background
            end
            
            
            eventCount = eventCount + 1;
            
        elseif  key ~= 'none' & (eventCount <= P.num_events_per_block)
            outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
            outP.err.WRONG_RESPONSE = outP.err.WRONG_RESPONSE + 1;
            outP.log.errors(eventCount) = "WRONG_RESPONSE";
            drawError(P, P.red, P.fixationColorRest); % flash a red background
            eventCount = eventCount + 1;
        end
        
    end
    blockP.actual_block_end = toc(P.start_of_run_tic);
    drawFixation(P, P.fixationColorRest);
catch E
    rethrow(E)
end

blockP.actual_block_end_II = toc(P.start_of_run_tic);
blockP.actual_block_duration = toc(start)
end

