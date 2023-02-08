%% MIDI Experiment
% The purpose this experiment is to examine the effect of laterality
% on auditory-motorintegration.
%
% Methods & Design:
% Participants will perform a task using a MIDI keyboard and headphones.
% The task has five phases:

%     - a motor only localizer
%     - auditoiry only localizer
%     - playing with sound - the familiraity phase
%     - The experiment itself, alternatly playing with either hand
%       while hearing in either ear


%% Setting up

%% paths
clc; clear; clear all;
addpath(fullfile(pwd));
addpath(fullfile(pwd, 'Auxiliary_Functions_MIDI_exp'));
addpath(fullfile(pwd, 'instruction_images'));

output_dir = fullfile(pwd, 'output_data');

%% init psychtoolbox & screens
Screen('Preference', 'VisualDebugLevel', 3); % skip PTB's intro screen
Screen('Preference', 'SkipSyncTests', 2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
green=[0,1,0];
gray = [120, 120, 120];

% [window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
% text preferences
% Screen('TextSize', window, P.textSize);
P.window = [];
%% initialize sound card
InitializePsychSound(1);
nrchannels = 2;
tm=2; % try change to 2 on exp pc...

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
P.subject_number = input('Please enter the subject''s number\n');

%% Initialize Data Table parameters
P.parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'ear',    'hand',   'error'};
P.var_types =  {'double',  'double',    'double',     'double',       'string',  'string', 'string'};

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
if bShowDisplay
    % [window, xCenter, yCenter] = init_screen('fullscreen');
    
    if bSmallDisplay
        global small_window small_xCenter small_yCenter;
        [small_window, small_xCenter, small_yCenter] = init_screen('small');     end
end

%% init run numbers for filenames
i_run = 1;
i_run_mot = 1;
i_run_aud = 1;

running_count = 0;

%% Start the main loop - waiting for user input
while true
    running_count = running_count + 1;
    str = sprintf('%s\n',...
                  "Which part would you like to run next?", ...
                  "ml - motor localizer", ...
                  "al - auditory localizer", ...
                  "sr - a short run with 4 blocks", ...
                  "sc - a short sound check", ...
                  "kc - a short keyboard check", ...
                  "r - an experimental run", ...
                  "q - quit\n");

    command = input(str, 's');

    try
        switch command
          case 'ml'
            fprintf("Running a motor localizer\n")

            [table, table_filename] = ...
                createTable(P, 'motor_loc', int2str(i_run_mot));

            % for knowing later what we're supposed to run
            P.conditions = motor_only_conditions;
            P.run_num = 1;
            P.run_type = 'motor_loc';
            file_num = i_run_mot;

            i_run_mot = i_run_mot + 1;

          case 'al'
            fprintf("Running an auditory localizer\n")

            [table, table_filename] = ...
                createTable(P,'auditory_loc', int2str(i_run_aud));

            % for knowing later what we're supposed to run
            P.conditions = auditory_only_conditions;
            P.run_num = 1;
            P.run_type = 'auditory_loc';
            file_num = i_run_aud;

            i_run_aud = i_run_aud + 1;

          case 'sc'
            % TODO fixme
            fprintf("Running a short sound check...\n\n")

            input('\nboth ears (press enter)\n');
            % fprintf("both: (in 0.1s)\n")
            WaitSecs(0.1)
            playGeneratedSequence('both');

            input('\nR ear (press enter)\n');
            % fprintf("R: (in 0.1s)\n")
            WaitSecs(0.1)
            playGeneratedSequence('R');

            input('\nL ear (press enter)\n');
            % fprintf("L: (in 0.1s)\n")
            WaitSecs(0.1)
            playGeneratedSequence('L');

            running_count = running_count - 1;
            continue

          case 'sr'
            fprintf("Running a short run (4 blocks)\n")
            [table, table_filename] = createTable(P,'audiomotor_short', int2str(i_run));
            P.run_num = 1;
            file_num = 1;
            P.run_type = 'audiomotor_short';
            P.conditions = short_conditions;
            running_count = running_count - 1;

            WaitSecs(0.1);

          case 'kc'
            fprintf("Running a keyboard check\n")

            fprintf("FIXME")

            WaitSecs(0.1);

            running_count = running_count - 1;
            continue

          case 'r'
            [table, table_filename] = createTable(P, ...
                                                  'audiomotor',...
                                                  int2str(i_run));

            fprintf("Running a full experimental run (20 blocks)\n")

            if mod(i_run, 2);
                curr_ear = "L";
            else
                curr_ear = "R";
            end

            disp_str = sprintf('\n%s\n',...
                               "Which ear to run?", ...
                               "L - left", ...
                               "R- right", ...
                               "Enter - %s (default based on previous run)\n\n");

            disp_str = sprintf(disp_str, curr_ear);

            ear_input = input(disp_str, 's');

            if ear_input ~= "" % we didn't get ENTER, override the default
                curr_ear = ear_input;
            end

            if curr_ear == 'L'
                P.conditions = left_conditions;
            else
                P.conditions = right_conditions;
            end

            % for knowing later what we're supposed to run
            P.run_num = i_run;
            P.run_type = 'audiomotor';
            file_num = i_run;

            i_run = i_run + 1;

          case 'q'
            break

          case 'i'
            init_screen('small') % small window
            init_screen('fullscreen')
            running_count = running_count - 1;
            continue

          otherwise
            running_count = running_count - 1;
            continue

        end % end switch-case

        %% run the chosen condition
        [table, shuffled_conditions] = ...
            single_run(P, table);

        WaitSecs(0.1);

        save(fullfile(output_dir, table_filename), "table");
        writetable(table, fullfile(output_dir, table_filename + ".xls"));

        clear table
        fprintf("******\n  Done!\n******\n\n")

    catch E
                rethrow(E)
        msgText = getReport(E,'basic');
        fprintf("Caught exception: %s\n", msgText)
    end % end try/catch
end % end while(true)


% end slide
WaitSecs(0.1);
instruction = imread('thank_you_end.JPG');
display_image(instruction, window);


% wait for a key press in order to continue
RestrictKeysForKbCheck([]);
fprintf("Press any key to continue\n");
KbWait;
sca;

