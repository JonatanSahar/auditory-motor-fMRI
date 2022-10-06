%% MIDI Experiment
% The purpose this experiment is to examine the effect of laterality
% on auditory-motorintegration.
%
% Methods & Design:
% Participants will perform a task using a MIDI keyboard and headphones.
% The task has six phases:

%     1. Phase 1: teaching subjects to play (without auditory feedback for now)
%     2. Phase 2a: a motor only localizer + baseline for modulation
%     3. Phase 2b: auditoiry only localizer
%     4. Phase 3: playing with sound - the familiarity phase
%     5. Phase 4: The experiment itself, alternatly playing with either hand
%                 while hearing in either ear
%     6. Phase 5b: Second motor-only  run

% Remaining tasks:
% TODO: make sure that the monaural playback works well on the lab computer
%

clc; clear; clear all;
addpath(fullfile(pwd));
addpath(fullfile(pwd, 'Auxiliary_Functions_MIDI_exp'));
addpath(fullfile(pwd, 'instruction_images'));
Screen('Preference', 'SkipSyncTests', 2);
% Unify keyboard names across software platforms
KbName('UnifyKeyNames');

%% Define Parameters
skipLocalizers = 0;

num_runs = 1  ;
num_runs_motor_localizer = 2;
num_blocks = 4; % should be 20, must be multiple of 4.
seq_length = 5;
num_seqs_in_block = 2;
num_notes = seq_length * num_seqs_in_block;

block_duration = 8; % in seconds
rest_duration = 5; % in seconds, between blocks
block_and_rest_duration = block_duration + rest_duration;
table_lines_per_block = num_runs + 1; % runs + familiarity
% start times of blocks, starting with a rest period
block_end_times = [block_and_rest_duration : block_and_rest_duration : block_and_rest_duration * (num_blocks)];
block_start_times = [rest_duration:block_and_rest_duration:block_and_rest_duration * (num_blocks)];

%% Experiment Initialization
% get subject's details
% group = input('Please enter group number\n(1 = LE, 2 = RE)    \n');

% subject_number = input('Please enter the subject''s number\n');
subject_number = 1;

% connect to midi device
% device = mididevice('Teensy MIDI');
device = mididevice('LoopBe Internal MIDI');
%% Initialize Data Tables
% wanted parameters
parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'ear',    'hand'};
var_types =  {'double',  'double',    'double',     'double',       'string',  'string'};

midi_parameters = {'run_num', 'block_num', 'time_stamp', 'note', 'is_on', 'ipi'};
midi_var_types =  {'double',  'double',    'double',    'double', 'double', 'double'};

% create tables
[motor_only_pre_table, motor_only_pre_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'motor_only_pre');

[motor_only_post_table, motor_only_post_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'motor_only_post');

[auditory_only_table, auditory_only_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'auditory_only');

[auditory_motor_table, auditory_motor_table_filename] = createTable(num_blocks, table_lines_per_block, parameters, var_types, subject_number, 'auditory_motor');

[midi_table, midi_table_filename] = createMidiTable(num_runs, num_blocks, num_notes, midi_parameters, midi_var_types, subject_number, 'midi');


% create an assignment of conditions per block
no_sound = [0, 0];
left_ear = [1, 1];
right_ear = [2, 2];
both_ears = [1, 2];
no_motor = [0, 0];
hands = [1, 2];

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.
[X, Y] = meshgrid(left_ear, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
left_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.
[X, Y] = meshgrid(right_ear, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
right_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.
[X, Y] = meshgrid(no_sound, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
motor_only_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.
[X, Y] = meshgrid(both_ears, no_motor);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
auditory_only_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);


% initialize screen
% HideCursor // TODO: restore
[window, rect] = init_screen();
win_hight = rect(4) - rect(2);
win_width = rect(3) - rect(1);
%    
%     auditory_motor_single_run(window, ...
%         device, ...
%         midi_table, ...
%         auditory_motor_table, ...
%         right_conditions,...
%         num_notes, ...
%         num_blocks, ...
%         block_start_times, ...
%         block_end_times, ...
%         0); % 0 = familiarity
% 
     auditory_only_table =  auditory_localizer(window, ...
        auditory_only_table, ...
        auditory_only_conditions, ...
        num_blocks, ...
        block_start_times, ...
        block_end_times)
    
if ~skipLocalizers
    %% Phase 1: teaching subjects to play (without auditory feedback for now)
    % TODO: decide how to do this - display a single slide with the sequence and let them practice by themselves? a block design to tell them which hand to practice with? inside or outside the scanner (or both)?
    WaitSecs(0.5);
    
    %% Phase 2a: a motor only localizer + baseline for modulation
    % TODO: create instruction images for motor localizer
    motor_only_pre_table = motor_localizer(window, device, motor_only_pre_table, motor_only_conditions, ...
        num_blocks, num_notes, block_start_times, block_end_times);
   
    WaitSecs(0.5);

    %% Phase 2b: auditoiry only localizer
    % TODO: create instruction images for auditiory localizer
    auditory_only_table =  auditory_localizer(window, ...
        auditory_only_table, ...
        auditory_only_conditions, ...
        num_blocks, ...
        block_start_times, ...
        block_end_times);

end %skipLocalizers
    WaitSecs(0.5);
    
    %% Phase 3: playing with sound - the familiarity phase
    
    auditory_motor_single_run(window, ...
        device, ...
        midi_table, ...
        auditory_motor_table, ...
        right_conditions,...
        num_notes, ...
        num_blocks, ...
        block_start_times, ...
        block_end_times, ...
        0); % 0 = familiarity
    % catch
    % clc; clear; clear screen;
    % end
    WaitSecs(0.5);
    
%% Phase 4: The experiment

for i_run = 1:num_runs
    conditions = right_conditions;
    if mod(i_run, 2)
        conditions = left_conditions;
    end
    
    [auditory_motor_table, midi_table] = auditory_motor_single_run(window, ...
        device, ...
        midi_table, ...
        auditory_motor_table, ...
        conditions,...
        num_notes, ...
        num_blocks, ...
        block_start_times, ...
        block_end_times, ...
        i_run);
    
    WaitSecs(0.5);
    
end


%% Phase 5b: Second motor-only run  TODO: decide if we want to extend this and use it to compare with the silent playing from before the experiment.
if ~skipLocalizers
motor_localizer(window, device, motor_only_post_table, motor_only_conditions, ...
    num_blocks, num_notes, block_start_times, block_end_times)
end % skipLocalizers

% end slide
WaitSecs(0.5);
instruction = imread('thank_you_end.JPG');
display_image(instruction, window);


% wait for a key press in order to continue
fprintf("Press any key to continue");
KbWait;
WaitSecs(0.5);
sca;

%% Export Tables to Excel and Disconnect MIDI
excel_path = fullfile(pwd, 'output_data');

writetable(motor_only_post_table, fullfile(excel_path, motor_only_post_table_filename));
writetable(auditory_only_table, fullfile(excel_path, auditory_only_table_filename));
writetable(auditory_motor_table, fullfile(excel_path, auditory_motor_table_filename));
writetable(motor_only_pre_table, fullfile(excel_path, motor_only_pre_table_filename));
writetable(midi_table, fullfile(excel_path, midi_table_filename));

    
