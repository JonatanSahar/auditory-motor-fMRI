% receive and synthesize note messages from midi in real time
function outP = single_block_auditory(P, blockP)
    fprintf("Play!\n");
    err_type = 0;
    outP.err.WRONG_RESPONSE  = 0;
    outP.err.MISSED_CUE  = 0;
    while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
        P.lastStimTic = tic;
        drawFixation(P, P.fixationColorGo);
        playSound(P, blockP.ear, false)
        waitForTimeOrEsc(P.IPI, true, P.lastStimTic);
    end
end
