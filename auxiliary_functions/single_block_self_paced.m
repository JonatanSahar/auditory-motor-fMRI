% receive and synthesize note messages from midi in real time
function outP = single_block_self_paced(P, blockP)
    start = tic;
    fprintf("Play!\n");
    err_counter = 0;
    outP.duration = 0;
    outP.err.WRONG_RESPONSE  = 0;
    outP.err.TOO_MANY_EVENTS  = 0;
    outP.err.INCOMPLETE = 0;
    outP.log.pressTimes = [];
    outP.log.cueTimes = [];
    outP.log.errors = [];

    try % a single block
        eventCount = 1;
        waitForTimeOrEsc(P.IPI, true, blockP.start_of_block_tic);
        drawFixation(P, P.fixationColorGo);
        while (toc(P.start_of_run_tic) <= blockP.end_of_block_time)
            key = waitForResponseBox();

            if isCorrectKey(key, blockP.hand) & (eventCount <= P.num_events_per_block)
                outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
                outP.log.cueTimes(eventCount) = toc(P.start_of_run_tic);

                if  eventCount == P.num_events_per_block
                    changeFixationColors(P, P.green, P.fixationColorRest); % flash a green background
                end

                playSound(P, blockP.ear, blockP.bMute)

                if  eventCount == P.num_events_per_block
                    changeFixationColors(P, P.gray, P.fixationColorRest); % flash a green background
                end

                outP.log.errors(eventCount) = "NONE";
                outP.duration = toc(blockP.start_of_block_tic);

                eventCount = eventCount + 1;

            elseif  key ~= 'none' & (eventCount <= P.num_events_per_block)
                outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
                outP.err.WRONG_RESPONSE = outP.err.WRONG_RESPONSE + 1;
                outP.log.errors(eventCount) = "WRONG_RESPONSE";
                drawError(P, P.red, P.fixationColorRest); % flash a red background
                eventCount = eventCount + 1;

            elseif isCorrectKey(key, blockP.hand) % more presses than were specified
                playSound(P, blockP.ear, blockP.bMute)
                outP.log.pressTimes(eventCount) = toc(P.start_of_run_tic);
                outP.log.errors(eventCount) = "TOO_MANY_EVENTS";
                outP.err.TOO_MANY_EVENTS = outP.err.TOO_MANY_EVENTS + 1;
            end
        end
        if eventCount < P.num_events_per_block
            outP.err.INCOMPLETE = outP.err.INCOMPLETE + 1;
        end
        blockP.actual_block_end = toc(P.start_of_run_tic);
        drawFixation(P, P.fixationColorRest);
    catch E
        rethrow(E)
    end
    blockP.actual_block_duration = toc(start)
end

