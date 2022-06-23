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
num_blocks = 2;
num_notes = 8; %sequence length

IPI = 0.3;
note_duration = 0.15;
block_duration = 3;
rest_duration = 2;
block_and_rest_duration = block_duration + rest_duration;
table_lines_per_block = 4; % 3 runs + familiarity
% start times of blocks, starting with a rest period
block_end_times = [block_and_rest_duration : block_and_rest_duration : block_and_rest_duration * (num_blocks)]
block_start_times = [rest_duration:block_and_rest_duration:block_and_rest_duration * (num_blocks)]


%% Experiment Initialization
% get subject's details
group = input('Please enter group number\n(1 = LE, 2 = RE)\n'); 
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
assert(mod(num_blocks, length(prod)) == 0);

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
motor_localizer(window, device, motor_only_data_table, conditions, ...
                num_blocks, block_start_times, block_end_times)
KbWait;
WaitSecs(0.5);

%% Phase 2b: auditoiry only localizer
auditory_localizer(window, device, auditory_only_data_table, conditions, ...
                   num_blocks, block_start_times, block_end_times)
KbWait;
WaitSecs(0.5);

%% Phase 3: playing with sound - the familiarity phase

auditory_motor_single_run(window, device, run_info_table, conditions, num_blocks, block_start_times, block_end_times, 0) % 0 = familiarity run
KbWait;
WaitSecs(0.5);


%% Phase 4: The experiment

for i_run = 1:num_runs
    auditory_motor_single_run(window, device, run_info_table, conditions, ...
                              num_blocks, block_start_times, ...
                              block_end_times, i_run)
    KbWait;
    WaitSecs(0.5);

end

%% Phase 5a: Motor Localizer (playing with no sound). TODO: decide if we want to extend this and use it to compare with the silent playing from before the experiment.
%TODO: complete.

% display post test instructions
Screen('FillRect', window, [172, 172, 172])
Screen('Flip', window);
instruct2 = imread('instruction_post_LH.jpg');
TexturePointer = Screen('MakeTexture',window, instruct2);
clear instruct2;
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);

% wait for a key press in order to continue
KbWait;
WaitSecs(0.5);


%% Phase 5b: Second motor-only run  TODO: decide if we want to extend this and use it to compare with the silent playing from before the experiment.

motor_localizer(window, device, motor_only_post_table, conditions, num_blocks, block_start_times, block_end_times)

% wait for a key press in order to continue
KbWait;
WaitSecs(0.5);
sca;

%% Export Tables to Excel and Disconnect MIDI
xl_path = fullfile(pwd, 'midi_data', 'LH');
writetable(run_info_table, fullfile(xl_path, info_table_filename));

function name = index_to_name(i)
    names = ['R', 'L'];
    name = names(i);
end


function motor_localizer(window, device, data_table, conditions, num_blocks, block_start_times, block_end_times)
      instruction = imread('motor_only_instructions.jpg');
      display_image(instruction, window);

     i_run = 1; % one localizer run
     shuffled_conditions = conditions(randperm(length(conditions)), :);

     % wait for a key press in order to continue
     % KbWait;
     % WaitSecs(0.5);
     waitForMRI()
     set_global_tic()
     for i_block = 1:num_blocks
          % get the start time of next block
         start_of_block_time = block_start_times(i_block);
         end_of_block_time = block_end_times(i_block);
         [ear, hand] = get_condition_for_block(shuffled_conditions, i_block)

         instruct_file = get_instruction_file_for_condition([ear hand]);
         instruction = imread(instruct_file);
         display_image(instruction, window);

         waitForTimeOrEsc(start_of_block_time, true, get_global_tic());

         instruction = imread('play.jpg');
         display_image(instruction, window);

         [start_time, duration] = processAndPlaybackMIDI(device, num_notes, window, 1, i_block, 'both', true);
         data_table = updateTable(data_table, num_blocks, i_run, i_block, index_to_name(ear), index_to_name(hand), start_time, duration)

         waitForTimeOrEsc(end_of_block_time, true, get_global_tic());

     end
end


function auditory_localizer(window, device, data_table, conditions, num_blocks, block_start_times, block_end_times)
      instruction = imread('auditory_only_instructions.jpg');
      display_image(instruction, window);

     i_run = 1; % one localizer run
     shuffled_conditions = conditions(randperm(length(conditions)), :);

     % wait for a key press in order to continue
     % KbWait;
     % WaitSecs(0.5);
     waitForMRI()
     set_global_tic()
     for i_block = 1:num_blocks
          % get the start time of next block
         start_of_block_time = block_start_times(i_block);
         end_of_block_time = block_end_times(i_block);
         [ear, hand] = get_condition_for_block(shuffled_conditions, i_block)

         instruct_file = get_instruction_file_for_condition([ear hand]);
         instruction = imread(instruct_file);
         display_image(instruction, window);

         waitForTimeOrEsc(start_of_block_time, true, get_global_tic());

         instruction = imread('play.jpg');
         display_image(instruction, window);

         [start_time, duration] = processAndPlaybackMIDI(device, num_notes, window, 1, i_block, 'both', false);
         data_table = updateTable(data_table, num_blocks, i_run, i_block, index_to_name(ear), index_to_name(hand), start_time, duration)

         waitForTimeOrEsc(end_of_block_time, true, get_global_tic());

     end
end

function auditory_motor_single_run(window, device, data_table, conditions, num_blocks, block_start_times, block_end_times, i_run)
      instruction = imread('auditory_only_instructions.jpg');
      display_image(instruction, window);
      shuffled_conditions = conditions(randperm(length(conditions)), :);

     % wait for a key press in order to continue
     % KbWait;
     % WaitSecs(0.5);
     waitForMRI()
     set_global_tic()
     for i_block = 1:num_blocks
          % get the start time of next block
         start_of_block_time = block_start_times(i_block);
         end_of_block_time = block_end_times(i_block);
         [ear, hand] = get_condition_for_block(shuffled_conditions, i_block)

         instruct_file = get_instruction_file_for_condition([ear hand]);
         instruction = imread(instruct_file);
         display_image(instruction, window);

         waitForTimeOrEsc(start_of_block_time, true, get_global_tic());

         instruction = imread('play.jpg');
         display_image(instruction, window);

         [start_time, duration] = processAndPlaybackMIDI(device, num_notes, window, 1, i_block, 'both', false);
         data_table = updateTable(data_table, num_blocks, i_run, i_block, index_to_name(ear), index_to_name(hand), start_time, duration)

         waitForTimeOrEsc(end_of_block_time, true, get_global_tic());

     end
end
