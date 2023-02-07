close all
clear all


eyetracker = 0;
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
Screen('TextSize', window,50);
HideCursor;

    InitializePsychSound(1);
    nrchannels = 2;
    tm=0; % try change to 2 on exp pc...

%% Initializing eye tracking system %
%-----------------------------------------------------------------
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
end

resp=KbName('SPACE');

[y,freq]=audioread('./sound.wav');
wavedata=[y';y'];

pahandle = PsychPortAudio('Open',[],[],tm,freq,nrchannels);
PsychPortAudio('FillBuffer',pahandle,wavedata);
PsychPortAudio('Volume', pahandle,100);

p=0;
while ~p
    [keyIsDown,secs, keyCode] = KbCheck;
    PsychPortAudio('Start',pahandle);
    tic
    while toc<1
        [keyIsDown,secs, keyCode] = KbCheck;
    if keyCode(resp)
        p=1;
    end
    end
end
sca