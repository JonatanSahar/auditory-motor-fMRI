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
addpath(fullfile(pwd, 'instructions_bpm'));
Screen('Preference', 'SkipSyncTests', 2);
% Unify keyboard names across software platforms
KbName('UnifyKeyNames');
    
%% Define Parameters
num_blocks = 20;
seq_len = 8; %sequence len
seq_num = 5; % num of sequences in test
familiar_len = 16; %num presses
test_len = seq_len * seq_num; % num of key presses in a test block
train_len = seq_len * seq_num;
rest_len = 15; % in seconds
IPI = 0.3;
note_duration = 0.15;
block_duration = 8;
rest_duration = 8;
block_and_rest_duration = block_duration + rest_duration

% start times of blocks, starting with a rest period
run_timing = [rest_duration:block_and_rest_duration:block_and_rest_duration * (numBlocks+1)]


%% Experiment Initialization
% get subject's details
group = input('Please enter group number\n(1 = LE, 2 = RE)\n'); 
subject_number = input('Please enter the subject''s number\n');

% connect to midi device
device2 = mididevice('Teensy MIDI');

%% Initialize Data Tables
% wanted parameters
parameters = {'block_num', 'start_time', 'play_duration', 'ear', 'hand'};
var_types = {'double', 'double', 'double', 'string', 'string'};
% create tables
[run_info_table, info_table_filename] = createTable(2, test_len, parameters, var_types, subject_number, 'run_info', group);


% create an assignment of conditions per block
index_to_letter = ['R', 'L'];
ears = [1, 2];
hands = [1, 2];
[X, Y] = meshgrid(ears, hands);
prod = [X(:), Y(:)];
assert(mod(num_blocks, length(prod)) == 0);
conditions = repmat(prod, num_blocks/length(prod), 1);
conditions = conditions(randperm(length(conditions)), :);


% initialize screen
 % HideCursor // TODO: restore
 [window, rect] = Screen('openwindow',0,[0, 0, 0], [0 0 640 480]);
 win_hight = rect(4) - rect(2);
 win_width = rect(3) - rect(1); 

%% Phase 1: teaching subjects to play (without auditory feedback for now)

%% TODO: Phase 2a: add a silent scan (motor only), instructions and blocks
     instruction = imread('auditory_only_instructions.jpg');
     display_image(instruction, window);
     % wait for a key press in order to continue
     KbWait;
     WaitSecs(0.5);

     instruction = imread('play.jpg');
     display_image(instruction, window);



%% TODO: Phase 2b: add a passive listening (auditory only), instructions and blocks


%% Phase 3: playing with sound - the familiarity phase
% instruction slide
     instruction = imread('auditory_only_instructions.jpg');
     display_image(instruction, window);

     % wait for a key press in order to continue
     KbWait;
     WaitSecs(0.5);
     playMIDI(device, familiar_len, window, NaN, 0);
     restTest(rest_len, window);
     playMIDI(device, familiar_len, window, NaN, 0);
     load(fullfile(pwd, 'seq_mat'));



%% Phase 4: The experiment - a single run for now. TODO: decide how to program 3 runs.

% instruction slide + 20 blocks
% black screen during training and white screen during rest

% display experiment instructions
Screen('FillRect', window, [172, 172, 172])
Screen('Flip', window);
instruct2 = imread('instruction_train_LH.jpg');
TexturePointer = Screen('MakeTexture',window, instruct2);
clear instruct2;
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);
% wait for a key press in order to continue
KbWait;
WaitSecs(0.5);

% start the loop for this run
for i_block = 1 : num_blocks
    % TODO: display instructions on which hand to play with, and which ear to expect feedback to.
    disp(i_block)
    run_info_table = playMIDI_t(group, device, train_len, window, run_info_table, i_block);
    % force the wait to end exactly when we want the
    % next block to start.
    timeToWait = runTiming(i + 1)
    waitForTimeOrEsc(timeToWait, 1, startTic);
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


%% Phase 5b: Auditory Localizer (passive listening). TODO: decide if we want to extend this and use it to compare with the silent playing from before the experiment.
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
sca;

%% Export Tables to Excel and Disconnect MIDI
xl_path = fullfile(pwd, 'midi_data', 'LH');
writetable(run_info_table, fullfile(xl_path, info_table_filename));


