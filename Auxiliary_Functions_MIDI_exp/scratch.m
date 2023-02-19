clc; clear; clear all; sca
addpath(fullfile(pwd));
addpath(fullfile(pwd, 'Auxiliary_Functions_MIDI_exp'));
addpath(fullfile(pwd, 'instruction_images'));

P.output_dir = fullfile(pwd, 'output_data');

%% init psychtoolbox & screens
Screen('Preference', 'VisualDebugLevel', 3); % skip PTB's intro screen
Screen('Preference', 'SkipSyncTests', 2);
screens = Screen('Screens');
P.screenNumber = max(screens);
P.white = WhiteIndex(P.screenNumber);
P.black = BlackIndex(P.screenNumber);
P.green=[147, 197, 114];
P.red=[199, 0, 57];
P.gray = [230, 230, 230];

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

P.bShowDisplay = 0;

P.bShowSmallDisplay = 1;

%% run % block parameters

P.num_runs = 4; % should be 4
P.num_blocks_short = 4;
P.num_blocks = 20; % should be 20, must be multiple of 4.
assert(mod(P.num_blocks, 4) == 0);

P.num_events_per_block = 6; % number of button presses in a block
instruction_display_duration = 1; % in seconds
block_duration = 9; %9 in seconds
rest_duration = 8; %8 in seconds, between blocks
rest_duration_short = 3; % in seconds, between blocks

%% fixation parameters
P.fixCrossDim = 50; %size of fixation cross in pixels
P.fixationCoords = [[-P.fixCrossDim P.fixCrossDim 0 0]; ...
                    [0 0 -P.fixCrossDim P.fixCrossDim]];
P.lineWidthFixation = 8; %line width of fixaton cross in pixels
P.fixationColorGo = P.green;
P.fixationColorRest = P.black;
P.fixationDisplayDuration = 0.8;
% [top-left-x, top-left-y, bottom-right-x, bottom-right-y].
P.stimDim=[0 0 185 185];
P.textSize = 54;

%% sounds
% TODO: fixme
[P.sound.y,P.sound.freq]=audioread('./audio_files/middleC.ogg');
P.sound.y=P.sound.y(1:end);
P.sound.wavedata=[P.sound.y';P.sound.y'];
P.sound.right = [zeros(size(P.sound.y'));P.sound.y'];
P.sound.left = [P.sound.y';zeros(size(P.sound.y'))];

P.IPI = 2
P.volume = 10;

%% logging

if demo_run % override values for a shorter run
    P.num_runs = 1;
    P.num_blocks = 4;
    block_duration = 8; %8 in seconds
    rest_duration = 1; %8 in seconds, between blocks
end

%% Calculate block timings (at what times to display everything)
block_and_rest_duration = block_duration + rest_duration;
cycle_time = block_and_rest_duration + instruction_display_duration; % block+washout+instruction display

block_and_rest_duration_short = block_duration + rest_duration_short;
cycle_time_short = block_and_rest_duration_short + instruction_display_duration; %

% start times of blocks, starting with a rest period
% the instruction_display_time is always the time the fixation break *ends* on
% +1 because we need to wait one last fixation/wash-out after the last block, and the wait is always until the next instruction
P.instruction_display_times = [rest_duration : ...
                               cycle_time : ...
                               cycle_time * (P.num_blocks + 1)];
P.block_start_times = P.instruction_display_times + instruction_display_duration;
P.block_end_times = P.block_start_times + block_duration;

P.instruction_display_times_short = [rest_duration_short : ...
                                     cycle_time_short : ...
                                     cycle_time_short * (P.num_blocks_short + 1)];

P.block_start_times_short = P.instruction_display_times_short + instruction_display_duration;
P.block_end_times_short = P.block_start_times_short + block_duration;


%% Experiment Initialization
P.subject_number = 3;

%% Initialize Data Table parameters
P.parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'ear',    'hand',   'MISSED_CUE', 'WRONG_RESPONSE'};
P.var_types =  {'double',  'double',    'double',     'double',       'string',  'string', 'string', 'string'};

% init a dummy midi table


%% create an assignment of conditions per block
no_sound = [0, 0];
left_ear = [1, 1];
right_ear = [2, 2];
both_ears = [1, 2];
no_motor = [0, 0];
hands = [1, 2];

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.

% short run
[X, Y] = meshgrid(right_ear,hands);
condition_pairs = [X(:), Y(:)];
assert(mod(P.num_blocks_short, length(condition_pairs)) == 0);
short_conditions = repmat(condition_pairs, P.num_blocks_short/length(condition_pairs), 1);


% L ear runs
[X, Y] = meshgrid(left_ear, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(P.num_blocks, length(condition_pairs)) == 0);
left_conditions = repmat(condition_pairs, P.num_blocks/length(condition_pairs), 1);


% R ear runs
[X, Y] = meshgrid(right_ear, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(P.num_blocks, length(condition_pairs)) == 0);
right_conditions = repmat(condition_pairs, P.num_blocks/length(condition_pairs), 1);

% motor localizer
[X, Y] = meshgrid(no_sound, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(P.num_blocks, length(condition_pairs)) == 0);
motor_only_conditions = repmat(condition_pairs, P.num_blocks/length(condition_pairs), 1);


% auditory localizer
[X, Y] = meshgrid(both_ears, no_motor);
condition_pairs = [X(:), Y(:)];
assert(mod(P.num_blocks, length(condition_pairs)) == 0);
auditory_only_conditions = repmat(condition_pairs, P.num_blocks/length(condition_pairs), 1);


%% screen initialization
window = 0; % dummy window variable
if P.bShowDisplay
    [P.window, P.xCenter, P.yCenter] = init_screen(P, 'fullscreen');
end

if P.bShowSmallDisplay
    [P.small_window, P.small_xCenter, P.small_yCenter] = init_screen(P, 'small');
end

%% init run numbers for filenames
i_run = 1;
i_run_mot = 1;
i_run_aud = 1;

running_count = 0;

fprintf("Running a short run (4 blocks)\n")
[table, table_filename] = createTable(P,'audiomotor_short', int2str(i_run));
P.run_num = 1;
file_num = 1;
P.run_type = 'audiomotor_short';
P.conditions = short_conditions;
running_count = running_count - 1;

WaitSecs(0.1);


[table, shuffled_conditions, outP] = ...
    single_run(P, table);

log.cueTimes = outP.log.cueTimes;
log.pressTimes = outP.log.pressTimes;
log.errors = outP.log.errors;
log.blockConditionsInOrder = shuffled_conditions;
WaitSecs(0.1);

save(fullfile(P.output_dir, table_filename), "table");
save(fullfile(P.output_dir, table_filename + "_log"), "log");
writetable(table, fullfile(P.output_dir, table_filename + ".xls"));

clear table
fprintf("******\n  Done!\n******\n\n")
sca
