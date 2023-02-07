close all
clear all
sca;
%Add_Psych; %  add psychtoolbox to the MRI computer             

sca
clc
%pause on
%% get participant data
params=backgroundData();
%% initiate psychtoolbox
disp(['run type: ',num2str(params.trialOrder(1,1,3))])
pause(2);
try
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen 
Screen('Preference', 'SkipSyncTests', 1); %change to 0 in real experiment
PsychDefaultSetup(2); % call some default settings for setting up Psychtoolbox
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
green=[0,1,0];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window); %get the size of the scrren in pixel
[xCenter, yCenter] = RectCenter(windowRect); % Get the centre coordinate of the window in pixels
% text preferences
Screen('TextSize', window,params.textSize);
catch
%     try
%     sca;
%     pause(1);
%     Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
% Screen('Preference', 'SkipSyncTests', 0); %change to 0 in real experiment
% PsychDefaultSetup(2); % call some default settings for setting up Psychtoolbox
% screens = Screen('Screens');
% screenNumber = max(screens);
% white = WhiteIndex(screenNumber);
% black = BlackIndex(screenNumber);
% green=[0,1,0];
% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
% [screenXpixels, screenYpixels] = Screen('WindowSize', window); %get the size of the scrren in pixel
% [xCenter, yCenter] = RectCenter(windowRect); % Get the centre coordinate of the window in pixels
% % text preferences
% Screen('TextSize', window,params.textSize);
%     catch
            sca;
    pause(1);
    Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
Screen('Preference', 'SkipSyncTests', 1); %change to 0 in real experiment
PsychDefaultSetup(2); % call some default settings for setting up Psychtoolbox
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
green=[0,1,0];
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window); %get the size of the scrren in pixel
[xCenter, yCenter] = RectCenter(windowRect); % Get the centre coordinate of the window in pixels
% text preferences
Screen('TextSize', window,params.textSize);
%     end
end
%%
HideCursor;

if params.trialOrder(1,1,3) == 2
    %% initialize sound card
    InitializePsychSound(1);
    nrchannels = 2;
    tm=2; % try change to 2 on exp pc...
end

% response buttons
KbName('UnifyKeyNames');
l=KbName('r');
a=KbName('b');
t=KbName('t');
resp=KbName('SPACE');
esc=KbName('ESCAPE');
params.blockType={'R','L'};
if params.sessionType == 1 && params.trialOrder(1,1,3) == 2
    howMany='./inst/howMany_sound.tif';
else
    howMany='./inst/howMany.tif';
end
params.instructions=['./inst/',num2str(params.sessionType),num2str(params.trialOrder(1,1,3)),'.tif'];

escape=0;
%% create visual stimulus
% Screen resolution in Y
screenYpix = windowRect(4);
% Number of white/black circle pairs
rcycles = 20;
% Number of white/black angular segment pairs (integer)
tcycles = 20;
% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim/3.7: 2 * xylim / (screenYpix - 1): xylim/3.7,...
    -xylim/3.7: 2 * xylim / (screenYpix - 1): xylim/3.7);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= (xylim/3.7)^2;
checks = circle .* checks + black * ~circle;
% Now we make this into a PTB texture
radialCheckerboardTexture  = Screen('MakeTexture', window, checks);

%% response parameters
log.RT=nan(params.blocksPerRun,params.eventsPerBlock);
log.falsePress=nan(params.blocksPerRun,params.eventsPerBlock); %% this array gets the RT of presses made with the wrong hand
log.countCatch=0;
log.stimulusPresentTime=nan(params.blocksPerRun,params.eventsPerBlock,2); %% first dim- stim appears, second din stim disappears row- trail number col- block number
log.cueTime = nan(params.blocksPerRun,params.eventsPerBlock,1); %% col- trail number row- block number
%% Initializing eye tracking system %
%-----------------------------------------------------------------
if params.eyetracker && params.runNum~=0
    dummymode=0;
    % STEP 2
    % Provide Eyelink with details about the graphics environment
    % and perform some initializations. The information is returned
    % in a structure that also contains useful defaults
    % and control codes (e.g. tracker state bit and Eyelink key values).
    el=EyelinkInitDefaults(window);
    % Disable key output to Matlab window:
    el.backgroundcolour = black;
    el.backgroundcolour = black;
    el.foregroundcolour = white;
    el.msgfontcolour    = white;
    el.imgtitlecolour   = white;
    el.calibrationtargetcolour = el.foregroundcolour;

    %% disable sounds
    el.targetbeep=0;  % sound a beep when a target is presented
    el.feedbackbeep=0;  % sound a beep after calibration/drift correction
    el.cal_target_beep=[1250 0 0.05];
    el.drift_correction_target_beep=[1250 0 0.05];
    el.calibration_failed_beep=[400 0 0.25];
    el.calibration_success_beep=[800 0 0.25];
    el.drift_correction_failed_beep=[400 0 0.25];
    el.drift_correction_success_beep=[800 0 0.25];
    %%
    EyelinkUpdateDefaults(el);
    % STEP 3
    % Initialization of the connection with the Eyelink Gazetracker.
    % exit program if this fails.
    if ~EyelinkInit(dummymode, 1)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    [v,ELversion]=Eyelink('GetTrackerVersion');
    fprintf('Running experiment on a ''%s'' tracker.\n', ELversion );
    % make sure that we get gaze data from the Eyelink
    Eyelink('Command', 'link_sample_data = LEFT,RIGHT,GAZE,HREF,AREA');
    % open file to record data to
    edfFile='RM_batel.edf';
    Eyelink('Openfile', edfFile);
    % STEP 4
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    % STEP 5
    % start recording eye position
    Eyelink('StartRecording');
    % record a few samples before we actually start displaying
    WaitSecs(0.1);
    %%%%%%%%%%%%%%%%%%%%%%%%%
    % Finish Initialization %
    %%%%%%%%%%%%%%%%%%%%%%%%%
    Eyelink('Message',['Events code in the file: ',...
        'block num (2 digits), event number in the block (1 digit), what was presented']);
    Eyelink('Message',['Presented item code: ',...
        '1 - green cross apears 2 - press/sound  3 - stimulus presentation 4 - white fixation cross screen'...
        ,' 6 - wrong response/no response screen (red X), 5- hand instruction appears']);
    Eyelink('Message',['e.g. the code 0115 means this is the first block, first event, hand instructions appeared']);
end
%% get cue from MRI
if params.training ~= 1
    if params.eyetracker
        Eyelink('Message',['Wait for t screen appers, run ',num2str(params.runNum)]);
    end
%     DrawFormattedText(window, ...
%         [ 'Scan number ', num2str(params.runNum), ' out of ', num2str(params.numRuns(params.sessionType)), ' is about to start.'], 'center', 'center', white);
%     Screen('Flip', window);
        ima=imread(params.instructions, 'TIF');
%         ima = logical(ima)*255;
        Screen('PutImage', window, ima); % put image on screen
        Screen('Flip', window);
    t_pressed = false;
    DisableKeysForKbCheck([]);
    while t_pressed == false
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(t)
            t_pressed = true;
        end
        if keyCode(esc)
            Screen('CloseAll');
            clear all
            return
        end
    end
    DisableKeysForKbCheck(t);
    log.practice=0;
end
Screen('TextSize', window,params.textSize);
%% start experiment
startRun=tic;
Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
Screen('Flip', window);
countCatch=0;
loaded = 0;
while toc(startRun)<8
        [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(esc)
        escape=1;
        break
    end
    if params.trialOrder(1,1,3) == 2 && ~loaded
        pahandle2 = PsychPortAudio('Open',[],[],tm,params.sound.freq,nrchannels);
        PsychPortAudio('FillBuffer',pahandle2,params.sound.wavedata{1}*0);
        PsychPortAudio('Start',pahandle2);
        loaded=1;
        pause(0.2);
        PsychPortAudio('Close',pahandle2);
        pahandle = PsychPortAudio('Open',[],[],tm,params.sound.freq,nrchannels);
        PsychPortAudio('FillBuffer',pahandle,params.sound.wavedata{params.trialOrder(1,1,2)+1});
%        PsychPortAudio('Volume', pahandle,params.volume);
    end
end
for j=1:size(params.trialOrder,1)/params.eventsPerBlock
    block=tic;
    if escape
        break
    end
    if params.eyetracker
        if j<10
            Eyelink('Message',['0',num2str(j),'1','1','5']);
        else
            Eyelink('Message',[num2str(j),'1','1','5']);
        end
    end
    if params.trialOrder(1,1,3) ~= 3
        DrawFormattedText(window, params.blockType{params.trialOrder(j*params.eventsPerBlock,1,2)+1} , 'center', 'center', white);
        Screen('Flip', window);
        while toc(block)<(params.instTime-0.2)
        end
        if params.eyetracker
            if j<10
                Eyelink('Message',['0',num2str(j),'1','4']);
            else
                Eyelink('Message',[num2str(j),'1','4']);
            end
        end
        Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
        Screen('Flip', window);
        while toc(block)<params.instTime
        end
    end
    for i=1:params.eventsPerBlock
        event=tic;
        if params.eyetracker
            if j<10
                Eyelink('Message',['0',num2str(j),num2str(i),'1']);
            else
                Eyelink('Message',[num2str(j),num2str(i),'1']);
            end
        end
        Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorGo, [xCenter yCenter], 2);
        Screen('Flip', window);
        rt=tic;
        if params.trialOrder(1,1,3) == 1
        pressed=0;
        while ~pressed
            [keyIsDown ,sec, keyCode] = KbCheck;
            if (keyCode(l)&&params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock+i,1,2)==0)||...
                    (keyCode(a)&&params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock+i,1,2)==1)
                log.RT(j,i)=toc(rt);
                log.cueTime(j,i)=toc(startRun);
                pressed=1;
                delay = tic;
                Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
                Screen('Flip', window);
                if params.eyetracker
                    if j<10
                        Eyelink('Message',['0',num2str(j),num2str(i),'2']);
                    else
                        Eyelink('Message',[num2str(j),num2str(i),'2']);
                    end
                end
                while toc(delay)<params.delayTime
                end
            elseif (keyCode(a)&&params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock+i,1,2)==0)||...
                    (keyCode(l)&&params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock+i,1,2)==1)
                log.falsePress(j,i)=toc(rt);
                log.RT(j,i)=nan;
                Screen('TextSize', window, 120);
                if params.eyetracker
                    if j<10
                        Eyelink('Message',['0',num2str(j),num2str(i),'6']);
                    else
                        Eyelink('Message',[num2str(j),num2str(i),'6']);
                    end
                end
                err=tic;
                DrawFormattedText(window, 'X' ,'center', 'center', [1,0,0]);
                Screen('Flip', window);
                while toc(err)<0.3
                end
                if params.eyetracker
                    if j<10
                        Eyelink('Message',['0',num2str(j),num2str(i),'4']);
                    else
                        Eyelink('Message',[num2str(j),num2str(i),'4']);
                    end
                end
%                 time=falsePress(j,i);
                pressed=1;
                Screen('TextSize', window, params.textSize);
            elseif keyCode(esc)
                escape=1;
                break
            elseif toc(rt)>(params.eventTime - params.DispTime - params.delayTime) 
                if params.eyetracker
                    if j<10
                        Eyelink('Message',['0',num2str(j),num2str(i),'6']);
                    else
                        Eyelink('Message',[num2str(j),num2str(i),'6']);
                    end
                end
                err=tic;
                Screen('TextSize', window, 120);
                DrawFormattedText(window, 'X' ,'center', 'center', [1,0,0]);
                Screen('Flip', window);
                while toc(err)<0.3
                end
                if params.eyetracker
                    if j<10
                        Eyelink('Message',['0',num2str(j),num2str(i),'4']);
                    else
                        Eyelink('Message',[num2str(j),num2str(i),'4']);
                    end
                end
                pressed=1;
                log.RT(j,i)=nan;
                Screen('TextSize', window, params.textSize);
            end
        end
        elseif params.trialOrder(1,1,3) == 2
            log.RT(j,i) = (params.eventTime - params.DispTime - params.delayTime -0.1)*rand(1,1) + 0.1;
            loaded = 0;
            while toc(rt)<log.RT(j,i)
                if params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock+i,1,1) && params.sessionType == 1 && ~loaded
                    PsychPortAudio('Close',pahandle);
                    pahandle = PsychPortAudio('Open',[],[],tm,params.sound.freq,nrchannels);
                    PsychPortAudio('FillBuffer',pahandle,params.sound.wavedata{params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock + i,1,2)+3});
%                    PsychPortAudio('Volume', pahandle,params.volume);
%                     PsychPortAudio('Start',pahandle);
%                     pause(0.05)
                    countCatch = countCatch + 1;
                    loaded = 1;
                end
                [keyIsDown ,sec, keyCode] = KbCheck;
                if keyCode(esc)
                    escape=1;
                    break
                end
            end
            log.cueTime(j,i)=toc(startRun);
            PsychPortAudio('Start',pahandle);
%             if loaded
%                 pause(0.15);
%                 log.cueTime(j,i)=toc(startRun);
%                 PsychPortAudio('Start',pahandle);
%             end
            delay = tic;
            pause(0.05);
            if params.eyetracker
                if j<10
                    Eyelink('Message',['0',num2str(j),num2str(i),'2']);
                else
                    Eyelink('Message',[num2str(j),num2str(i),'2']);
                end
            end
            while toc(delay)<params.delayTime
                if loaded
                    PsychPortAudio('Close',pahandle);
                    pahandle = PsychPortAudio('Open',[],[],tm,params.sound.freq,nrchannels);
                    PsychPortAudio('FillBuffer',pahandle,params.sound.wavedata{params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock + i + 1,1,2)+1});
%                    PsychPortAudio('Volume', pahandle,params.volume);
                    loaded = 0;
                end
                [keyIsDown ,sec, keyCode] = KbCheck;
                if keyCode(esc)
                    escape=1;
                    break
                end
            end
        else

        end
        if escape
            break
        elseif params.trialOrder(1,1,3) == 1 && isnan(log.RT(j,i))
            Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
            Screen('Flip', window);
            while toc(event)<params.eventTime
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(esc)
                    escape=1;
                    break
                end
            end
        else
            if params.sessionType == 2 || params.trialOrder(1,1,3) == 3
                log.stimulusPresentTime(j,i,1)=toc(startRun);
                if ~params.trialOrder(j*params.eventsPerBlock-params.eventsPerBlock+i,1,1)
                    Screen('DrawTexture', window, radialCheckerboardTexture,[],[],[],[],[],[1,1,1]);
                else
                    Screen('DrawTexture', window, radialCheckerboardTexture,[],[],[],[],[],[0,0,1]);
                    countCatch=countCatch+1;
                end
                rt=toc(rt);
                Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
                Screen('Flip', window);
                if params.eyetracker
                    if j<10
                        Eyelink('Message',['0',num2str(j),num2str(i),'3']);
                    else
                        Eyelink('Message',[num2str(j),num2str(i),'3']);
                    end
                end
                while toc(event)<(params.DispTime+rt)
                    [keyIsDown,secs, keyCode] = KbCheck;
                    if keyCode(esc)
                        escape=1;
                        break
                    end
                end
                log.stimulusPresentTime(j,i,2)=toc(startRun);
            end
            Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
            Screen('Flip', window);
            if params.eyetracker
                if j<10
                    Eyelink('Message',['0',num2str(j),num2str(i),'4']);
                else
                    Eyelink('Message',[num2str(j),num2str(i),'4']);
                end
            end
            Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
            Screen('Flip', window);
            while toc(event)<params.eventTime
                [keyIsDown,secs, keyCode] = KbCheck;
                if keyCode(esc)
                    escape=1;
                    break
                end
            end
        end
%         toc(block);
    end
    if escape
        break
    else
        Screen('DrawLines', window, params.FixationCoords, params.lineWidthFixation, params.fixationColorRest, [xCenter yCenter], 2);
            Screen('Flip', window);
            louded=0;
        while toc(block)<params.blockDuration
            [keyIsDown,secs, keyCode] = KbCheck;
            if keyCode(esc)
                escape=1;
                break
            end
            if params.trialOrder(1,1,3) == 2 && ~louded && j<size(params.trialOrder,1)/params.eventsPerBlock
                PsychPortAudio('Close',pahandle);
                pahandle = PsychPortAudio('Open',[],[],tm,params.sound.freq,nrchannels);
                PsychPortAudio('FillBuffer',pahandle,params.sound.wavedata{params.trialOrder((j+1)*params.eventsPerBlock-params.eventsPerBlock + 1,1,2)+1});
%                PsychPortAudio('Volume', pahandle,params.volume);
                louded=1;
            end
        end
        log.blockTime(j)=toc(block);
    end
end
%%
log.endTime=toc(startRun);
%%catch count display
if ~escape
    if params.eyetracker
        Eyelink('Message','end');
        Eyelink('Message','Catch count screen');
    end
    if ~(params.sessionType == 1 && params.trialOrder(1,1,3) == 1)
        ima=imread(howMany, 'TIF');
%         ima = logical(ima)*255;
        Screen('PutImage', window, ima); % put image on screen
        Screen('Flip', window);
        respbool=0;
        while ~respbool
            [keyIsDown,secs, keyCode] = KbCheck;
            if any(keyCode)
                log.countCatch=find(keyCode);
                respbool=1;
            end
        end
        DrawFormattedText(window, num2str(countCatch) ,'center', 'center', white);
        Screen('Flip', window);
        WaitSecs(1);
    else
        ShowCursor;
        sca;
    end
end
% save variables
if ~params.training
    save([params.outDir,'\',params.subject,'Session',num2str(params.sessionType),'Run',num2str(params.runNum)]);
end
if params.eyetracker
    Eyelink('StopRecording');
    WaitSecs(.1);
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
catch
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end
    Eyelink('shutdown');
end
if params.eyetracker && exist(edfFile)
    dirc=pwd;
    system(['rename ',dirc,'\',edfFile, ' ' num2str(params.subject) 'session' num2str(params.sessionType) 'Run' num2str(params.runNum),'.edf'])
         movefile([num2str(params.subject) 'session' num2str(params.sessionType) 'Run' num2str(params.runNum),'.edf'],params.outDir)
end  
%%   
%% close psychtoolbox   
if ~(params.sessionType == 1 && params.trialOrder(1,1,3) == 1)
    KbWait;
    ShowCursor;
    sca;
elseif escape
    ShowCursor;
    sca;
end
% PsychPortAudio('Closeall');
%Remove_Psych; % remove psychtoolbox from MRI computer
if params.sessionType == 1
    orderFile = [params.outDir,'\trialOrder_Session1.mat'];
else
    orderFile = [params.outDir,'\trialOrder_Session2.mat'];
end
    load(orderFile);
if params.runNum ~= params.numRuns(params.sessionType)
    disp(['next run type: ',num2str(trialOrder(1,params.runNum+1,3))]);
end