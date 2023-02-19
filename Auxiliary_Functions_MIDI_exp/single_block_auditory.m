% receive and synthesize note messages from midi in real time
function outP = single_block_auditory(P, blockP)
fprintf("Play!\n");
err_type = 0;
outP.err.WRONG_RESPONSE  = 0;
outP.err.MISSED_CUE  = 0;
eventCount = 1;
while (toc(P.start_of_run_tic) <= blockP.end_of_block_time) & eventCount <= P.num_events_per_block
    P.lastStimTic = tic;
    drawFixation(P, P.fixationColorGo);
    playSound(P, blockP.ear, false)
    
    if  eventCount == P.num_events_per_block
        drawError(P, P.green, P.fixationColorRest); % flash a green background
    end
    
    
    waitForTimeOrEsc(P.IPI, true, P.lastStimTic);
    eventCount = eventCount + 1;
    
    
end

end
