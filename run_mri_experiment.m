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
parameters = {'block', 'block_start_time'};
var_types = {'double', 'double'};
% create tables
[run_info_table, test_filename] = createTable(2, test_len, parameters, ...
                                              var_types, subject_number, 'run_info', group);

% %% Familiarity Phase
% initialize screen
 HideCursor;
 [window, rect] = Screen('openwindow',0,[0, 0, 0], [0 0 640 480]);
 win_hight = rect(4) - rect(2);
 win_width = rect(3) - rect(1); 
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



%% The experiment itslef
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
    disp(i_block)
    train_table = playMIDI_t(group, device, train_len, window, train_table, i_block);
    train_table = restTrain_v2(rest_len, window, device, train_len, ...
    train_table, num_blocks, i_block, win_hight, win_width);
end

%% Post-Test Phase

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

% display headphones and play sequence
Screen('FillRect', window, [255, 255, 255])
Screen('Flip', window);
instruct5 = imread('headphones.jpg');
TexturePointer = Screen('MakeTexture',window, instruct5);
clear instruct5;
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);
pause(1);
load(fullfile(pwd, 'seq_mat'));
playSequence(seq_mat, IPI);
WaitSecs(0.5);

% first hand test
[post_test_table] = playMIDI(device, test_len, window, post_test_table, 1);
restTest(rest_len, window);
[post_test_table] = playMIDI(device, test_len, window, post_test_table, 2);

% switch hands
Screen('FillRect', window, [172, 172, 172])
Screen('Flip', window);
instruct2 = imread('instruction_post_RH.jpg');
TexturePointer = Screen('MakeTexture',window, instruct2);
clear instruct2;
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);
% wait for a key press in order to continue
KbWait;
WaitSecs(0.5);

% display headphones and play sequence
Screen('FillRect', window, [255, 255, 255])
Screen('Flip', window);
instruct5 = imread('headphones.jpg');
TexturePointer = Screen('MakeTexture',window, instruct5);
clear instruct5;
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);
pause(2);
load(fullfile(pwd, 'seq_mat'));
playSequence(seq_mat, IPI);
WaitSecs(0.5);

% second hand test
[post_test_table] = playMIDI(device, test_len, window, post_test_table, 3);
restTest(rest_len, window);
[post_test_table] = playMIDI(device, test_len, window, post_test_table, 4);

% close psychtoolbox window
Screen('FillRect', window, [172, 172, 172])
Screen('Flip', window);
instruct6 = imread('finish.jpg');
TexturePointer = Screen('MakeTexture',window, instruct6);
clear instruct6;
Screen('DrawTexture',window, TexturePointer);
Screen('Flip', window);
% wait for a key press in order to continue
KbWait;
WaitSecs(0.5);
sca;

%% Export Tables to Excel and Disconnect MIDI
xl_path = fullfile(pwd, 'midi_data', 'LH');
writetable(run_info_table, fullfile(xl_path, test_filename));
writetable(train_table, fullfile(xl_path, train_filename));
writetable(post_test_table, fullfile(xl_path, post_test_filename));
