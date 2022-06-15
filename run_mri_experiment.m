%% MIDI Experiment
% The purpose this experiment is to examine the effect of lateralized 
% auditory feedback on motor skill improvement on 2 consecutive days.
% Methods & Design:
% Participants are allocated into 2 groups: LH-LE, LH-RE. 
% R/L = right/left, H/E = hand/ear. 
% Task will be performed with MIDI keyboard and headphones.
% The task has four phases:
% 1. familiarization - participants will repeat sequence x 2 for each hand on MIDI keyboard.
% 2. pre-training test: participants play the keyboard sequence with both hands 
%    (one at a time) while auditory feedback is sent to both ears.   
% 3. training phase: 20 blocks * (5 seq repetitions + 15 sec rest)
%    training is performed with one hand and auditory feedbback is given in

%    one ear according to the participant's assigned group.
% 4. post-training test: participants play the keyboard sequence with both hands 
%    (one at a time) while auditory feedback is sent to both ears.
% extraction of relevant data for analysis: pressed note, press timestamp

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
 % HideCursor
 [window, rect] = Screen('openwindow',0,[0, 0, 0], [0 0 640 480]);
 win_hight = rect(4) - rect(2);
 win_width = rect(3) - rect(1); 

%% Phase 1: teaching subjects to play (without auditory feedback for now)

%% TODO: Phase 2a: add a silent scan (motor only), instructions and blocks
%% TODO: Phase 2b: add a passive listening (auditory only), instructions and blocks


%% Phase 3: playing with sound - the familiarity phase
% instruction slide
     Screen('FillRect', window, [172, 172, 172])
     Screen('Flip', window);
     instruct1 = imread('instruction_fam.jpg');
     TexturePointer = Screen('MakeTexture',window, instruct1);
     clear instruct1;
     Screen('DrawTexture',window, TexturePointer);
     Screen('Flip', window);
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
    run_info_table = restTrain_v2(rest_len, window, device, train_len, ...
    run_info_table, num_blocks, i_block, win_hight, win_width);
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
