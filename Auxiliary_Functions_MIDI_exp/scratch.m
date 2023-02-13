sca
Screen('Preference', 'VisualDebugLevel', 3); % skip PTB's intro screen
Screen('Preference', 'SkipSyncTests', 2);
screens = Screen('Screens');
P.screenNumber = max(screens);

P.output_dir = fullfile(pwd, 'output_data');
P.white = WhiteIndex(screenNumber);
P.black = BlackIndex(screenNumber);
P.green=[25, 208, 0];
P.red=[199, 0, 57];
P.gray = [127, 127, 127];
% P.gray = [243, 243, 243];
P.fixationColorGo = P.green;
P.fixationColorRest = P.black;
P.doRotate = @(theta, X) ([cosd(theta) -sind(theta); sind(theta) cosd(theta)] * X);


P.interPressInterval = 2;
P.fixationDisplayDuration = 0.8;
blockP.block_num = 1;
[P.window, P.xCenter, P.yCenter] = init_screen('small');

P.lineWidthFixation = 8; %line width of fixaton cross in pixels
P.fixCrossDim = 50; %size of fixation cross in pixels
P.fixationCoords = [[-P.fixCrossDim P.fixCrossDim 0 0]; ...
                    [0 0 -P.fixCrossDim P.fixCrossDim]];

for i = 1:length(P.fixationCoords)
    X(:, i) = P.doRotate(45, P.fixationCoords(:,i))
end

P.errorCoords = X

blockP.end_of_block_time = 5;
P.start_of_run_tic = tic;
P.run_start_time = toc(P.start_of_run_tic);
blockP.currentHand = 'R';
blockP.err.WRONG_RESPONSE  = 0;
blockP.err.MISSED_CUE  = 0;

P.log.cueTimes = nan(P.num_blocks,P.num_events_per_block);
P.log.pressTimes = nan(P.num_blocks,P.num_events_per_block);
P.log.errors = strings(P.num_blocks,P.num_events_per_block);

eventCount = 1;
blockP.actualStartOfBlockTime = toc(P.start_of_run_tic);
while ((toc(P.start_of_run_tic)) <= blockP.end_of_block_time)
    drawFixation(P, P.fixationColorGo);
    P.lastStimTic = tic;
    P.log.cueTimes(blockP.block_num, eventCount) = toc(P.start_of_run_tic);
    pressed=0;

    key = waitForResponseBox(P, P.fixationDisplayDuration)
    P.log.pressTimes(blockP.block_num, eventCount) = toc(P.start_of_run_tic);
    if key ~= 'none' & isCorrectKey(key, blockP.currentHand)
        drawFixation(P, P.fixationColorRest);
        P.log.errors(blockP.block_num, eventCount) = "NONE";
    else
        % incorrect buton pressed
        if key == 'none'
            blockP.err.MISSED_CUE =  blockP.err.MISSED_CUE + 1;
            P.log.errors(blockP.block_num, eventCount) = "MISSED_CUE";
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
log = P.log;
save(fullfile(P.output_dir, "test_log"), "log");
sca
