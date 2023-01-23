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
clc; clear; clear all;
addpath(fullfile(pwd));
addpath(fullfile(pwd, 'Auxiliary_Functions_MIDI_exp'));
addpath(fullfile(pwd, 'instruction_images'));
Screen('Preference', 'VisualDebugLevel', 3); % skip PTB's intro screen
Screen('Preference', 'SkipSyncTests', 2);
% Unify keyboard names across software platforms
KbName('UnifyKeyNames');
previousKeys = RestrictKeysForKbCheck([KbName('ESCAPE')]);

%% Define Parameters
use_virtual_midi = 0;
demo_run = 0;

global bShowDisplay;
bShowDisplay = 1;

global bSmallDisplay
bSmallDisplay = 1;

num_runs = 4; % should be 4
num_blocks_short = 4;
num_blocks = 20; % should be 20, must be multiple of 4.
assert(mod(num_blocks, 4) == 0);

seq_length = 7;
num_seqs_in_block = 2;
num_notes = seq_length * num_seqs_in_block;

instruction_display_duration = 1; % in seconds
block_duration = 9; %9 in seconds
rest_duration = 8; %8 in seconds, between blocks
rest_duration_short = 3; % in seconds, between blocks

if demo_run % override values for a shorter run
    num_runs = 1;
    num_blocks = 4;
    block_duration = 8; %8 in seconds
    rest_duration = 1; %8 in seconds, between blocks
end

output_dir = fullfile(pwd, 'output_data');

%% Calculate block timings (at what times to display everything)
block_and_rest_duration = block_duration + rest_duration;
cycle_time = block_and_rest_duration + instruction_display_duration; % block+washout+instruction display

block_and_rest_duration_short = block_duration + rest_duration_short;
cycle_time_short = block_and_rest_duration_short + instruction_display_duration; %

table_lines_per_block = num_runs + 1; % runs + familiarity

% start times of blocks, starting with a rest period
% the instruction_display_time is always the time the fixation break *ends* on
instruction_display_times = [rest_duration : ...
                             cycle_time : ...
                             cycle_time * (num_blocks + 1)]; % +1 because we need to wait one last fixation/washout after the last block, and the wait is always until the next instruction

block_start_times = instruction_display_times + instruction_display_duration;
block_end_times = block_start_times + block_duration;

instruction_display_times_short = [rest_duration_short : ...
                                   cycle_time_short : ...
                                   cycle_time_short * (num_blocks_short + 1)]; % see note above about +1

block_start_times_short = instruction_display_times_short + instruction_display_duration;
block_end_times_short = block_start_times_short + block_duration;


%% Experiment Initialization
subject_number = input('Please enter the subject''s number\n');

% connect to midi device
if use_virtual_midi
    midi_dev = mididevice('LoopBe Internal MIDI');
else
    midi_dev = mididevice('Teensy MIDI');
end


%% Initialize Data Table parameters
parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'ear',    'hand',   'error'};
var_types =  {'double',  'double',    'double',     'double',       'string',  'string', 'string'};

midi_parameters = {'run_num', 'block_num', 'time_stamp', 'note', 'is_on', 'ipi'};
midi_var_types =  {'double',  'double',    'double',    'double', 'double', 'double'};

% init a dummy midi table
midi_table = [];

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
assert(mod(num_blocks_short, length(condition_pairs)) == 0);
short_conditions = repmat(condition_pairs, num_blocks_short/length(condition_pairs), 1);


% L ear runs
[X, Y] = meshgrid(left_ear, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
left_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);


% R ear runs
[X, Y] = meshgrid(right_ear, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
right_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);

% motor localizer
[X, Y] = meshgrid(no_sound, hands);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
motor_only_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);


% auditory localizer
[X, Y] = meshgrid(both_ears, no_motor);
condition_pairs = [X(:), Y(:)];
assert(mod(num_blocks, length(condition_pairs)) == 0);
auditory_only_conditions = repmat(condition_pairs, num_blocks/length(condition_pairs), 1);


%% screen initialization
window = 0; % dummy window variable
if bShowDisplay
    [window, rect] = init_screen('fullscreen');
    
    if bSmallDisplay
        global small_window;
        [small_window, rect] = init_screen('small'); % uncomment in magent!
    end
end

%% init run numbers for filenames
i_run = 1;
i_run_mot = 1;
i_run_aud = 1;

running_count = 0;

%% Start the main loop - waiting for user input
while true
    running_count = running_count + 1;
    midi_table = [];
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

            [table, table_filename] = createTable(num_blocks, 1, parameters, var_types, subject_number, 'motor_loc', int2str(i_run_mot));

            conditions = motor_only_conditions;
            % for knowing later what we're supposed to run

            run_num = 1;
            run_type = 'motor_loc';
            file_num = i_run_mot;

            i_run_mot = i_run_mot + 1;

          case 'al'
            fprintf("Running an auditory localizer\n")

            [table, table_filename] = ...
                createTable(num_blocks,...
                            1,...
                            parameters,...
                            var_types,...
                            subject_number,...
                            'auditory_loc',...
                            int2str(i_run_aud));

            % for knowing later what we're supposed to run
            conditions = auditory_only_conditions;
            run_num = 1;
            run_type = 'auditory_loc';
            file_num = i_run_aud;

            i_run_aud = i_run_aud + 1;

          case 'sc'
            fprintf("Running a short sound check...\n\n")

            input('both ears (press enter)\n');
            % fprintf("both: (in 0.1s)\n")
            WaitSecs(0.1)
            playGeneratedSequence('both');

            input('R ear (press enter)\n');
            % fprintf("R: (in 0.1s)\n")
            WaitSecs(0.1)
            playGeneratedSequence('R');

            input('L ear (press enter)\n');
            % fprintf("L: (in 0.1s)\n")
            WaitSecs(0.1)
            playGeneratedSequence('L');

            running_count = running_count - 1;
            continue

          case 'sr'
            fprintf("Running a short run (4 blocks)\n")
            [table, table_filename] = createTable(num_blocks_short,...
                                                  1,...
                                                  parameters,...
                                                  var_types,...
                                                  subject_number,...
                                                  'audiomotor_short',...
                                                  int2str(i_run));
            run_num = 1;
            file_num = 1;
            run_type = 'audiomotor_short';
            conditions = short_conditions;
            running_count = running_count - 1;

            WaitSecs(0.1);

          case 'kc'
            fprintf("Running a keyboard check\n")

            playMIDI( ...
                midi_dev,...
                num_notes * 2, ...
                1, ...
                'both', ...
                'R', ...
                false, ...
                30,...
                tic)


            WaitSecs(0.1);

            running_count = running_count - 1;
            continue

          case 'r'
            [table, table_filename] = createTable(num_blocks,...
                                                  1,...
                                                  parameters,...
                                                  var_types,...
                                                  subject_number,...
                                                  'audiomotor',...
                                                  int2str(i_run));
            [midi_table, midi_table_filename] = ...
            createMidiTable(num_runs,...
                            num_blocks,...
                            num_notes,...
                            midi_parameters,...
                            midi_var_types,...
                            subject_number,...
                            'midi_',...
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
                "Enter - %s (default based on previous run)\n\n")

            disp_str = sprintf(disp_str, curr_ear);

            ear_input = input(disp_str, 's');

            if ear_input ~= "" % we didn't get ENTER, override the default
                curr_ear = ear_input;
            end

            if curr_ear == 'L'
                conditions = left_conditions;
            else
                conditions = right_conditions;
            end

            % for knowing later what we're supposed to run
            run_num = i_run;
            run_type = 'audiomotor';
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
        [table, midi_table, shuffled_conditions] = ...
            single_run(window, ...
                       midi_dev, ...
                       midi_table, ...
                       table, ...
                       conditions,...
                       num_notes, ...
                       num_blocks, ...
                       instruction_display_times, ...
                       block_start_times, ...
                       block_end_times, ...
                       run_num, ...
                       run_type);

            WaitSecs(0.1);

            writetable(table, fullfile(output_dir, table_filename));

            table.weight = ones(length(table.ear), 1);


            % % create an event file with all events to be separated later.
            % % 5 columns: time, duration, weight, ear, hand.
            % % tab delimited.  1 = L, 2 = R
            events_str = sprintf("%d_%d_events_%s(%d)",...
                                 running_count, ...
                                 subject_number,...
                                 run_type,...
                                 file_num);
            events_filename = events_str + ".mat";

            switch run_type
              case 'motor_loc'
                splitEventTable(table, 'hand', events_str, output_dir,...
                                ["start_time", "play_duration", "weight"]);
              case 'auditory_loc'
                splitEventTable(table, 'ear', events_str,...
                                output_dir,["start_time",...
                                            "play_duration", ...
                                            "weight"] );
              case 'audiomotor'
                % in each run, the ear is kept constant
                this_ear = table.ear(1);

                events_str = sprintf("%s_%s_ear", events_str, this_ear);
                splitEventTable(table, 'hand', events_str, output_dir, ...
                                ["start_time",...
                                 "play_duration",...
                                 "weight"]);

                % write the MIDI table to file
                writetable(midi_table,...
                           fullfile(output_dir, midi_table_filename));
            end

    clear table midi_data_table midi_table
    fprintf("******\n  Done!\n******\n\n")

    catch E
%         rethrow(E)
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

