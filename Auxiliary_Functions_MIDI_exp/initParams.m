Function params = initParams()
P.output_dir = fullfile(pwd, 'output_data');

%% init psychtoolbox & screens
Screen('Preference', 'VisualDebugLevel', 3); % skip PTB's intro screen
Screen('Preference', 'SkipSyncTests', 2);
screens = Screen('Screens');
P.screenNumber = max(screens);
P.white = WhiteIndex(screenNumber);
P.black = BlackIndex(screenNumber);
P.green=[0,1,0];
P.gray = [120, 120, 120];

% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% text preferences
% Screen('TextSize', window, P.textSize);
P.window = [];
%% initialize sound card
InitializePsychSound(1);
P.nrchannels = 2;
P.tm=2; % try change to 2 on exp pc...

%% response buttons
KbName('UnifyKeyNames');
r=KbName('r');
b=KbName('b');
t=KbName('t');
resp=KbName('SPACE');
esc=KbName('ESCAPE');
RestrictKeysForKbCheck([esc t r b]);

%% misc Parameters
demo_run = 1;

global bShowDisplay;
bShowDisplay = 0;

global bSmallDisplay
bSmallDisplay = 1;

%% run parameters

P.num_runs = 4; % should be 4
P.num_blocks_short = 4;
P.num_blocks = 20; % should be 20, must be multiple of 4.
assert(mod(P.num_blocks, 4) == 0);

% number of button presses in a block
P.num_events_per_block = 6;

instruction_display_duration = 1; % in seconds
block_duration = 9; %9 in seconds
rest_duration = 8; %8 in seconds, between blocks
rest_duration_short = 3; % in seconds, between blocks

%% display parameters
P.fixCrossDim = 20; %size of fixation cross in pixels
P.FixationCoords = [[-P.fixCrossDim P.fixCrossDim 0 0]; [0 0 -P.fixCrossDim P.fixCrossDim]];%setting fixation point coordinations
P.lineWidthFixation = 4; %line width of fixaton cross in pixels
P.fixationColorGo = [0,1,0];
P.fixationColorRest = [1,1,1];
P.StimDim=[0 0 185 185]; %Set Stimulus Dimantions [top-left-x, top-left-y, bottom-right-x, bottom-right-y].
P.textSize = 54;

%% sounds
% TODO: fixme
% [P.sound.y,P.sound.freq]=audioread('./sound.wav');
% P.sound.wavedata{1}=[zeros(size(P.sound.y'));P.sound.y']; %% only right ear feedback
% P.sound.wavedata{2}=[P.sound.y';zeros(size(P.sound.y'))]; %% only left ear feedback

P.volume = 10;

if demo_run % override values for a shorter run
    P.num_runs = 1;
    P.num_blocks = 4;
    block_duration = 8; %8 in seconds
    rest_duration = 1; %8 in seconds, between blocks
end


end
