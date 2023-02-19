% receive and synthesize note messages from midi in real time
function outP = single_block_self_paced(P, blockP)
fprintf("Play!\n");
err_type = 0;
outP.err.WRONG_RESPONSE  = 0;
outP.err.MISSED_CUE  = 0;

try % a single block
    eventCount = 1;
    waitForTimeOrEsc(P.IPI, true, blockP.start_of_block_tic);
    drawFixation(P, P.fixationColorGo);
    while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
        P.lastStimTic = tic;

        key = waitForResponseBox(P, P.fixationDisplayDuration)
        outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
        outP.log.cueTimes(eventCount) = toc(P.start_of_run_tic);
        if isCorrectKey(key, blockP.hand)
            playSound(P, blockP.ear, blockP.bMute)
            % WaitSecs(0.2);
            % drawFixation(P, P.fixationColorRest);
            outP.log.errors(eventCount) = "NONE";
        elseif  key ~= 'none'
            outP.err.WRONG_RESPONSE = outP.err.WRONG_RESPONSE + 1;
            outP.log.errors(eventCount) = "WRONG_RESPONSE";
            drawError(P, P.fixationColorRest); % flash a red background
        end
        eventCount = eventCount + 1;
    end
    drawFixation(P, P.fixationColorRest);
catch E
    rethrow(E)
end
