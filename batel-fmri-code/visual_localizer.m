close all;
clear all;
rng('Shuffle');
%Add_Psych; % add psychtoolbox to the MRI computer
sca
clc
% pause on
[subject, runNum, eyetracker]=localizerBackgroundData();
%% initiate psychtoolbox
HideCursor;
Screen('Preference', 'VisualDebuglevel', 3); %No PTB intro screen
Screen('Preference', 'SkipSyncTests', 1); %change to 0 in real experiment
PsychDefaultSetup(2); % call some default settings for setting up Psychtoolboxt
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
[screenXpixels, screenYpixels] = Screen('WindowSize', window); %get the size of the scrren in pixel
[xCenter, yCenter] = RectCenter(windowRect); %Get the centre coordinate of the window in pixels
%%
%% text preferences
Screen('TextSize', window, 54);
%% constant variables
% experiment length
frequency=5;
stimulusDuration=0.8; %in seconds
off_duration=0.7;
num_trials=6;
timeBetweenBlocks=9; %in seconds
blocksPerRun=16;
% blocksPerRun=4;
blockDuration=(stimulusDuration+off_duration)*num_trials+timeBetweenBlocks;
TR=1;
% response buttons
KbName('UnifyKeyNames');
t=KbName('t');
esc=KbName('ESCAPE');
% display parameters
fixCrossDim = 18.5; %size of fixation cross in pixels
FixationCoords = [[-fixCrossDim fixCrossDim 0 0]; [0 0 -fixCrossDim fixCrossDim]];%setting fixation point coordinations
lineWidthFixation = 2; %line width of fixaton cross in pixels
escape=0;
%% make visual stimulus
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
%% create trial order
direc=fullfile('.','dataFiles',num2str(subject));
localizerTrialOrder=[[ceil(screenXpixels/2) 0 screenXpixels screenYpixels];[0 0 ceil(screenXpixels/2) screenYpixels]];
localizerTrialOrder=(repmat(localizerTrialOrder,blocksPerRun/2,1));
localizerTrialOrder=localizerTrialOrder(Shuffle(1:blocksPerRun),:);
if ~exist(direc)
    mkdir(fullfile('.','dataFiles'),num2str(subject))
end
save(fullfile(direc,[num2str(subject),'localizerTrialOrdeRun',num2str(runNum),'.mat']),'localizerTrialOrder');
timing=nan(blocksPerRun,2);
%%
if eyetracker
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
    EyelinkUpdateDefaults(el);
    % STEP 3
    % Initialitttzation of the connection with the Eyelink Gazetracker.
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
    edfFile=[ subject,'Loc',num2str(runNum),'.edf'];
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
        'block num (2 digits), what was presented']);
    Eyelink('Message',['Presented item code: ',...
        '1- stimulus started 2- stimulus ended']);
end
%%
if eyetracker
    Eyelink('Message',['Wait for t screen appers, run ',num2str(runNum)]);
end
DrawFormattedText(window,'Scan is about to start.', 'center', 'center', white);
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
expTime=tic;
Screen('DrawLines', window, FixationCoords, lineWidthFixation, [1 0 0], [xCenter yCenter], 2);
Screen('Flip', window);
while toc(expTime)<timeBetweenBlocks
    [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(esc)
        escape=1;
        break
    end
end
for i=1:blocksPerRun
    if escape
        break
    end
    block=tic;
    for j=1:num_trials
        if eyetracker  %stimulus appears
            if i<10
                Eyelink('Message',['0',num2str(i),'1']);
            else
                Eyelink('Message',[num2str(i),'1']);
            end
        end
        event=tic;
        Screen('DrawTexture', window, radialCheckerboardTexture);
        Screen('DrawLines', window, FixationCoords, lineWidthFixation, [1 0 0], [xCenter yCenter], 2);
        Screen('Flip',window);
        timing(i,j,1)=toc(expTime);
        while toc(event)<stimulusDuration
        end
        Screen('DrawLines', window, FixationCoords, lineWidthFixation, [1 0 0], [xCenter yCenter], 2);
        Screen('Flip',window);
        timing(i,j,2)=toc(expTime);
        if eyetracker
            if i<10
                Eyelink('Message',['0',num2str(i),'2']); %stimulus ended
            else
                Eyelink('Message',[num2str(i),'2']);
            end
        end
        while toc(event)<stimulusDuration+off_duration
        end
    end
    while toc(block)<blockDuration
        [keyIsDown,secs, keyCode] = KbCheck;
        if keyCode(esc)
            escape=1;
            break
        end
    end
    toc(block);
end
expTime=toc(expTime);
if eyetracker
    Eyelink('StopRecording');
    WaitSecs(.1);
    Eyelink('CloseFile');
    try
        fprintf('Receiving data file ''%s''\n', edfFile );
        status=Eyelink('ReceiveFile');
        if status > 0
            fprintf('ReceiveFile status %d\n', status);
        end
        if 2==exist(edfFile, 'file')
            fprintf('Data file ''%s'' can be found in ''%s''\n', edfFile, pwd );
        end
    catch rdf
        fprintf('Problem receiving data file ''%s''\n', edfFile );
        rdf;
    end
    Eyelink('shutdown');
end
save(fullfile(direc,[subject,'LocalizerRun',num2str(runNum)]));
if eyetracker && exist(edfFile)
    movefile(edfFile,direc)
end
ShowCursor;
sca
%Remove_Psych; % remove psychtoolbox from MRI computer