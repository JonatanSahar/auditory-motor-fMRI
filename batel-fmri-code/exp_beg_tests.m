close all
clear all
sca;
%Add_Psych; %  add psychtoolbox to the MRI computer 
sca
clc

HideCursor;

orientationTest='./inst/text.tif';
soundTest='./inst/soundCheck.tif';

ima=imread(orientationTest, 'TIF');
ima2=imread(soundTest, 'TIF');

KbName('UnifyKeyNames');
rep = KbName('r');
space = KbName('space');
esc = KbName('escape');
right = KbName('x');
left = KbName('z');

eyetracker = 1;
escape = 0;

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

%% SOUND CHECK
% initialize sound card
InitializePsychSound(1);
nrchannels = 2;
tm=2;
[sound.y,sound.freq]=audioread('./long_sound2.wav');
sound.y=sound.y(1:end/2);
sound.wavedata=[sound.y';sound.y'];
sound.right = [zeros(size(sound.y'));sound.y'];
sound.left = [sound.y';zeros(size(sound.y'))];

pahandle2 = PsychPortAudio('Open',[],[],tm,sound.freq,nrchannels);
PsychPortAudio('FillBuffer',pahandle2,sound.wavedata);
%inst and whait for start
Screen('PutImage', window, ima2); % put image on screen
Screen('Flip', window);
p=0;
while ~p
    [keyIsDown ,sec, keyCode] = KbCheck;
    if keyCode(space) || keyCode(esc)
        p=1;
        if keyCode(esc)
            escape = 1;
        end
    end
end
good = 0;
while ~good && ~escape
    PsychPortAudio('Start',pahandle2);
    tic
    while toc<5 && ~escape
        [keyIsDown ,sec, keyCode] = KbCheck;
        if keyCode(esc)
            escape = 1;
        end
    end
    p=0;
    while ~p && ~escape
        [keyIsDown ,sec, keyCode] = KbCheck;
        if keyCode(space) || keyCode(rep) || keyCode(esc)
            p=1;
            if keyCode(space)
                good = 1;
            elseif keyCode(esc)
                escape =  1;
            end
        elseif keyCode(right)
PsychPortAudio('Close',pahandle2);
pahandle2 = PsychPortAudio('Open',[],[],tm,sound.freq,nrchannels);
PsychPortAudio('FillBuffer',pahandle2,sound.right);
    PsychPortAudio('Start',pahandle2);

        elseif keyCode(left)
PsychPortAudio('Close',pahandle2);
pahandle2 = PsychPortAudio('Open',[],[],tm,sound.freq,nrchannels);
PsychPortAudio('FillBuffer',pahandle2,sound.left);
    PsychPortAudio('Start',pahandle2);

        end
    end
end
WaitSecs(0.5);
PsychPortAudio('Close',pahandle2);

%% ORIENTATION CHECK
if ~escape
    Screen('PutImage', window, ima); % put image on screen
    Screen('Flip', window);
    p=0;
    while ~p
        [keyIsDown ,sec, keyCode] = KbCheck;
        if keyCode(space)
            p=1;
        end
    end
end
%% EYETRACKER
if eyetracker && ~escape
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
%     % STEP 5
%     % start recording eye position
%     Eyelink('StartRecording');
%     % record a few samples before we actually start displaying
%     WaitSecs(0.1);
%     %%%%%%%%%%%%%%%%%%%%%%%%%
%     % Finish Initialization %
%     %%%%%%%%%%%%%%%%%%%%%%%%%
%     Eyelink('Message',['Events code in the file: ',...
%         'block num (2 digits), event number in the block (1 digit), what was presented']);
%     Eyelink('Message',['Presented item code: ',...
%         '1 - green cross apears 2 - press/sound  3 - stimulus presentation 4 - white fixation cross screen'...
%         ,' 6 - wrong response/no response screen (red X), 5- hand instruction appears']);
%     Eyelink('Message',['e.g. the code 0115 means this is the first block, first event, hand instructions appeared']);
end

sca;
% 
%     Eyelink('StopRecording');
%     Eyelink('CloseFile');
