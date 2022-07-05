%% MIDI Experiment
% The purpose this experiment is to examine the effect of laterality
% on auditory-motorintegration.
%
% Methods & Design:
% Participants will perform a task using a MIDI keyboard and headphones.
% The task has six phases:
%
% Remaining tasks:
% TODO: complete documentation
% TODO: complete instruction slides + export to jpg
%
%

clc; clear; 
addpath(fullfile(pwd, 'Auxiliary_Functions_MIDI_exp'));
addpath(fullfile(pwd, 'instruction_images'));
Screen('Preference', 'SkipSyncTests', 2);
% Unify keyboard names across software platforms
KbName('UnifyKeyNames');
    
%% Define Parameters
num_runs = 4;
num_runs_motor_localizer = 2;
num_blocks = 4; % should be 20
num_notes = 8; % sequence length

block_duration = 5; % in seconds
rest_duration = 2; % in seconds
block_and_rest_duration = block_duration + rest_duration;
table_lines_per_block = num_runs + 1; % runs + familiarity
% start times of blocks, starting with a rest period
block_end_times = [block_and_rest_duration : block_and_rest_duration : block_and_rest_duration * (num_blocks)]
block_start_times = [rest_duration:block_and_rest_duration:block_and_rest_duration * (num_blocks)]


%% Experiment Initialization
% get subject's details
% group = input('Please enter group number\n(1 = LE, 2 = RE)\n'); 
subject_number = input('Please enter the subject''s number\n');

% connect to midi device
device = mididevice('Teensy MIDI');

%% Initialize Data Tables
% wanted parameters
parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'ear', 'hand'};
var_types = {'double', 'double', 'double', 'double', 'string', 'string'};

% create tables

[motor_only_pre_table, info_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'motor_only_pre');

[motor_only_post_table, info_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'motor_only_post');

[auditory_only_table, info_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'auditory_only');

[run_info_table, info_table_filename] = createTable(num_blocks, table_lines_per_block, parameters, var_types, subject_number, 'run_info');

% create an assignment of conditions per block
ears = [1, 2];
hands = [1, 2];
[X, Y] = meshgrid(ears, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.
conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);

% initialize screen
 % HideCursor // TODO: restore
[window, rect] = init_screen();
win_hight = rect(4) - rect(2);
win_width = rect(3) - rect(1);

%% Phase 1: teaching subjects to play (without auditory feedback for now)
% TODO: decide how to do this - display a single slide with the sequence and let them practice by themselves? a block design to tell them which hand to practice with? inside or outside the scanner (or both)?
KbWait;
WaitSecs(0.5);

%% Phase 2a: a motor only localizer + baseline for modulation
KbWait;
WaitSecs(0.5);

%% Phase 2b: auditoiry only localizer
auditory_localizer(window, device, auditory_only_table, conditions, ...
                   num_blocks, block_start_times, block_end_times)
KbWait;
WaitSecs(0.5);

%% Phase 3: playing with sound - the familiarity phase

 auditory_motor_single_run(window, device, ...
                              run_info_table, conditions,...
                              num_blocks, block_start_times, ...
                              block_end_times, 0, ...
                              num_notes); % 0 = familiarity 
runKbWait;
WaitSecs(0.5);


%% Phase 4: The experiment

for i_run = 1:num_runs
    auditory_motor_single_run(window, device, ...
                              run_info_table, conditions,...
                              num_blocks, block_start_times, ...
                              block_end_times, i_run, ...
                              num_notes);

    KbWait;
    WaitSecs(0.5);

end

%% Phase 5a: Motor Localizer (playing with no sound). TODO: decide if we want to extend this and use it to compare with the silent playing from before the experiment.
KbWait;
WaitSecs(0.5);


%% Phase 5b: Second motor-only run  TODO: decide if we want to extend this and use it to compare with the silent playing from before the experiment.

motor_localizer(window, device, motor_only_post_table, conditions, ...
                num_blocks, block_start_times, block_end_times)

sca;

%% Export Tables to Excel and Disconnect MIDI
xl_path = fullfile(pwd, 'midi_data', 'LH');
writetable(run_info_table, fullfile(xl_path, info_table_filename));






