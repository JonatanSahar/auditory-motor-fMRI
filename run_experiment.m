%% MIDI Experiment
% The purpose this experiment is to examine the effect of laterality
% on auditory-motorintegration.
%
% Methods & Design:
% Participants will perform a task using a MIDI keyboard and headphones.
% The task has five phases:

%     1. Phase 1: teaching subjects to play (without auditory feedback for now)
%     2. Phase 2a: a motor only localizer + baseline for modulation
%     3. Phase 2b: auditoiry only localizer
%     4. Phase 3: playing with sound - the familiraity phase
%     5. Phase 4: The experiment itself, alternatly playing with either hand
%                 while hearing in either ear

% Remaining tasks:
% TODO: make sure that the monaural playback works well on the lab computer
%

clc; clear; clear all;
addpath(fullfile(pwd));
addpath(fullfile(pwd, 'Auxiliary_Functions_MIDI_exp'));
addpath(fullfile(pwd, 'instruction_images'));
Screen('Preference', 'VisualDebugLevel', 3); % skip PTB's intro screen
Screen('Preference', 'SkipSyncTests', 2);
% Unify keyboard names across software platforms
KbName('UnifyKeyNames');

%% Define Parameters
skip_to_experiment = 0;
use_virtual_midi = 1;
demo_run = 1;


INVALID_RUN_NUM = 0;

num_runs = 3; % should be 3

num_blocks_fam = 4;
num_blocks = 20; % should be 20, must be multiple of 4.

if demo_run % override values for a shorter run
    num_runs = 1; 
    num_blocks_fam = 4;
    num_blocks = 4; 
end

assert(mod(num_blocks, 4) == 0);
seq_length = 5;
num_seqs_in_block = 2;
num_notes = seq_length * num_seqs_in_block;

instruction_display_duration = 2; % in seconds


block_duration = 8; %8 in seconds
rest_duration = 8; %8 in seconds, between blocks
rest_duration_fam = 3; % in seconds, between blocks
block_and_rest_duration = block_duration + rest_duration;
cycle_time = block_and_rest_duration + instruction_display_duration; % block+washout+instruction display
block_and_rest_duration_fam = block_duration + rest_duration_fam;
cycle_time_fam = block_and_rest_duration_fam + instruction_display_duration; %
table_lines_per_block = num_runs + 1; % runs + fam

% start times of blocks, starting with a rest period
% the instruction_display_time is always the time the fixation break ends on
instruction_display_times = [rest_duration : ...
                             cycle_time : ...
                             cycle_time * (num_blocks + 1)]; % +1 because we need to wait one last fixation/washout after the last block, and the wait is always until the next instruction

block_start_times = instruction_display_times + instruction_display_duration;
block_end_times = block_start_times + block_duration;

instruction_display_times_fam = [rest_duration_fam : ...
                     cycle_time_fam : ...
                                 cycle_time_fam * (num_blocks_fam + 1)]; % see note above about +1

block_start_times_fam = instruction_display_times_fam + instruction_display_duration;
block_end_times_fam = block_start_times_fam + block_duration;


%% Experiment Initialization
% get subject's details
% group = input('Please enter group number\n(1 = LE, 2 = RE)    \n');

subject_number = input('Please enter the subject''s number\n');
% subject_number = 1;

% connect to midi device
if use_virtual_midi
    device = mididevice('LoopBe Internal MIDI');
else
    device = mididevice('Teensy MIDI');
end


%% Initialize Data Tables
% wanted parameters
parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'ear',    'hand'};
var_types =  {'double',  'double',    'double',     'double',       'string',  'string'};

midi_parameters = {'run_num', 'block_num', 'time_stamp', 'note', 'is_on', 'ipi'};
midi_var_types =  {'double',  'double',    'double',    'double', 'double', 'double'};


% create an assignment of conditions per block
no_sound = [0, 0];
left_ear = [1, 1];
right_ear = [2, 2];
both_ears = [1, 2];
no_motor = [0, 0];
hands = [1, 2];

% one condition per block, in original order -
% shuffle it to get a randomized block order per run.
[X, Y] = meshgrid(right_ear,hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks_fam, length(condition_pairs)) == 0);
fam_conditions = repmat(condition_pairs, num_blocks_fam/length(condition_pairs), 1);

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
[window, rect] = init_screen(false);

global small_window
% [small_window, rect] = init_screen(true);

% init run numbers for filenames
i_run = 1;
i_run_mot = 1;
i_run_aud = 1;

excel_path = fullfile(pwd, 'output_data');

while true

    command = input('Which part would you like to run next? \nMOT - motor localizer \nAUD - auditory localizer \nSHORT - a short run with 4 blocks \nSOUND - a short sound check \nRUN - and experimental run\n\n', 's');

    try
    switch command
      case 'MOT'
      fprintf("Running a motor localizer\n")

      [motor_only_pre_table, motor_only_pre_table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'motor_only_pre', int2str(i_run_mot));

      [motor_only_pre_table, x] = single_run(window, ...
                                               device,...
                                               midi_table, ...
                                               motor_only_pre_table,...
                                               motor_only_conditions, ...
                                               num_notes, ...
                                               num_blocks,...
                                               instruction_display_times, ...
                                               block_start_times, ...
                                               block_end_times,...
                                               INVALID_RUN_NUM, 'motor_loc' );

        WaitSecs(0.5);
        writetable(motor_only_pre_table, fullfile(excel_path, motor_only_pre_table_filename));
        i_run_mot = i_run_mot + 1;

      case 'AUD'
        fprintf("Running a auditory localizer\n")

        [auditory_only_table, auditory_only_table_filename] = ...
            createTable(num_blocks, 1, parameters, var_types, ...
            subject_number, 'auditory_only', int2str(i_run_aud));

        [auditory_only_table, x] =  single_run(window, ...
                                               device, ...
                                               midi_table, ...
                                               auditory_only_table, ...
                                               auditory_only_conditions, ...
                                               num_notes, ...
                                               num_blocks,...
                                               instruction_display_times, ...
                                               block_start_times, ...
                                               block_end_times, ...
                                               INVALID_RUN_NUM, 'auditory_loc' );

        WaitSecs(0.5);
        writetable(auditory_only_table, fullfile(excel_path, auditory_only_table_filename));
        i_run_aud = i_run_aud + 1;

      case 'SOUND'
        fprintf("Running a short sound check\n")
         playSequence('both');
         WaitSecs(0.5)
         playSequence('R');
         WaitSecs(0.5)
         playSequence('L');

      case 'SHORT'
        fprintf("Running a short run (4 blocks)\n")
        single_run(window, ...
                   device, ...
                   midi_table, ...
                   auditory_motor_table, ...
                   fam_conditions,...
                   num_notes, ...
                   num_blocks_fam, ...
                   instruction_display_times_fam, ...
                   block_start_times_fam, ...
                   block_end_times_fam, ...
                   INVALID_RUN_NUM, ... % = familiraity run
                   'audiomotor');

        WaitSecs(0.5);

      case 'RUN'
        fprintf("Running a full experimental run (20 blocks)\n")

        [auditory_motor_table, auditory_motor_table_filename] = ...
            createTable(num_blocks, ...
                        table_lines_per_block, ...
                        parameters, ...
                        var_types, ...
                        subject_number, ...
                        'auditory_motor', int2str(i_run));


        if mod(i_run, 2);
            curr_ear = "L";
        else
            curr_ear = "R";
        end

    disp_str = sprintf("Which ear to run? \nEnter L or R, or Hit ENTER to use the default based on previous run - currently %s\", str)
        ear_input = input(disp_str, 's')

        if ear_input ~= "" % we didn't get ENTER, override the default
            curr_ear = ear_input;
        end

        if curr_ear == 'L'
            conditions = left_conditions;
        else
            conditions = right_conditions;
        end

        i_run = i_run + 1;

        [auditory_motor_table, midi_table] = ...
            single_run(window, ...
                       device, ...
                       midi_table, ...
                       auditory_motor_table, ...
                       conditions,...
                       num_notes, ...
                       num_blocks, ...
                       instruction_display_times, ...
                       block_start_times, ...
                       block_end_times, ...
                       i_run, ...
                       'audiomotor');

        WaitSecs(0.5);

        writetable(auditory_motor_table, fullfile(excel_path, auditory_motor_table_filename));
        writetable(midi_table, fullfile(excel_path, midi_table_filename));

    end

    catch E
        rethrow(E)
    end
end


% end slide
WaitSecs(0.5);
instruction = imread('thank_you_end.JPG');
display_image(instruction, window);


% wait for a key press in order to continue
fprintf("Press any key to continue\n");
KbWait;
WaitSecs(0.5);
sca;
