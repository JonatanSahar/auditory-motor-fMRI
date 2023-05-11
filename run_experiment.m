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


%% Notice
% the length of each run is 357 TRs (seconds)
%
% before the first block there's an 8sec fixation break.
% each block starts with a slide saying L/R for 1sec, followed by a fixation for 8sec,
% which turns green after IPI sec, during which the subject presses the button 6 times,
% and then another fixation for signal wash-out.
%
% in auditory blocks it's the same - a slide with R/L, then a fixation which turns green after IPI sec, and then a tones lasting 0.4sec separated by IPI sec between the start of one tone and the start of the next.


%% Setting up

%% paths
clc; clear; clear all; sca
addpath(fullfile(pwd));
addpath(fullfile(pwd, 'auxiliary_functions'));
addpath(fullfile(pwd, 'instruction_images'));

P.output_dir = fullfile(pwd, 'output_data');
P.debugOn = false;
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
P.latenceyReq=2; % try change to 2 on exp pc...

%% response buttons
KbName('UnifyKeyNames');
r=KbName('r');
b=KbName('b');
t=KbName('t');
resp=KbName('SPACE');
esc=KbName('ESCAPE');
RestrictKeysForKbCheck([esc t r b]);

%% misc Parameters
demo_run = 0;

P.bShowDisplay = 1;

P.bShowSmallDisplay = 1;

%% run % block parameters

P.num_runs = 4; % should be 4
P.num_blocks_short = 4;
P.num_blocks = 20; % should be 20, must be multiple of 4.
assert(mod(P.num_blocks, 4) == 0);

P.num_events_per_block = 8; % number of button presses in a block
instruction_display_duration = 1; % in seconds
block_duration = 8; %9 in seconds
rest_duration = 8; %8 in seconds, between blocks
rest_duration_short = 3; % in seconds, between blocks

%% fixation parameters
P.fixCrossDim = 50; %size of fixation cross in pixels
P.fixationCoords = [[-P.fixCrossDim P.fixCrossDim 0 0]; ...
                    [0 0 -P.fixCrossDim P.fixCrossDim]];
P.lineWidthFixation = 8; %line width of fixaton cross in pixels
P.fixationColorGo = P.green;
P.fixationColorRest = P.black;
P.fixationDisplayDuration = 1;
% [top-left-x, top-left-y, bottom-right-x, bottom-right-y].
P.stimDim=[0 0 185 185];
P.textSize = 54;

%% sounds
[P.sound.y,P.sound.freq]=audioread('./audio_files/middleC.ogg');
P.sound.y=P.sound.y(1:end);
P.sound.wavedata=[P.sound.y';P.sound.y'];
P.sound.right = [zeros(size(P.sound.y'));P.sound.y'];
P.sound.left = [P.sound.y';zeros(size(P.sound.y'))];
P.sound.silence = [zeros(size(P.sound.y'));zeros(size(P.sound.y'))];

[P.testSound.y,P.testSound.freq]=audioread('./audio_files/middleG.mp3');
P.testSound.y=P.testSound.y(1:end);
P.testSound.wavedata=[P.testSound.y';P.testSound.y'];
P.testSound.right = [zeros(size(P.testSound.y'));P.testSound.y'];
P.testSound.left = [P.sound.y';zeros(size(P.sound.y'))];


P.soundDuration = 0.3;
P.IPI = block_duration/(P.num_events_per_block+1);
% P.IPI = block_duration/P.num_events_per_block - P.soundDuration;
P.volume = 10;

P.pahandle = PsychPortAudio('Open',[],[],P.latenceyReq, [],P.nrchannels);

%% logging

if demo_run % override values for a shorter run
    P.num_runs = 1;
    P.num_blocks = 4;
    rest_duration = 1; %8 in seconds, between blocks
end

%% Calculate block timings (at what times to display everything)
block_and_rest_duration = block_duration + rest_duration;
cycle_time = block_and_rest_duration + instruction_display_duration; % block+washout+instruction display

block_and_rest_duration_short = block_duration + rest_duration_short;
cycle_time_short = block_and_rest_duration_short + instruction_display_duration; %

% start times of blocks, starting with a rest period
% the instruction_display_time is always the time the fixation break *ends* on and the L/R instruction is displayed (for fixations that appear after blocks, i.e not the first fixation of the run, this one ends on the first block_start_times time)
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
P.parameters = {'run_num', 'block_num', 'start_time', 'play_duration', 'last_press_time', 'end_time', 'ear',    'hand',   'TOO_MANY_EVENTS', 'WRONG_RESPONSE', 'INCOMPLETE', 'had_error', 'weight'};
P.var_types =  {'double',  'double',    'double', 'double', 'double', 'double', 'string',  'string', 'double', 'double', 'double', 'double', 'double'};

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
[X, Y] = meshgrid(left_ear,hands);
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


%% Start the main loop - waiting for user input
while true
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

            [eventTable, table_filename] = ...
                createTable(P, 'motorLoc', int2str(i_run_mot));

            % for knowing later what we're supposed to run
            P.conditions = motor_only_conditions;
            P.run_num = 1;
            P.run_type = 'motorLoc';
            file_num = i_run_mot;

            i_run_mot = i_run_mot + 1;

          case 'al'
            fprintf("Running an auditory localizer\n")

            [eventTable, table_filename] = ...
                createTable(P,'auditoryLoc', int2str(i_run_aud));

            % for knowing later what we're supposed to run
            P.conditions = auditory_only_conditions;
            P.run_num = 1;
            P.run_type = 'auditoryLoc';
            file_num = i_run_aud;

            i_run_aud = i_run_aud + 1;

          case 'sc'
            fprintf("Running a short sound check...\n\n")

            input('\nboth ears (press enter)\n');
            WaitSecs(0.1)
            playSampleSequence(P, 'both');

            input('\nR ear (press enter)\n');
            WaitSecs(0.1)
            playSampleSequence(P, 'R');

            input('\nL ear (press enter)\n');
            WaitSecs(0.1)
            playSampleSequence(P, 'L');

            continue

          case 'sr'
            fprintf("Running a short run (4 blocks)\n")
            [eventTable, table_filename] = createTable(P,'audiomotor_short', int2str(i_run));
            P.run_num = 1;
            file_num = 1;
            P.run_type = 'audiomotor_short';
            P.conditions = short_conditions;

            WaitSecs(0.1);

          case 'kc'
            fprintf("Running a keyboard check\n")

            hand = 'R';
            ear = 'both';
            timeToRun = 8;
            bMute = false;

            input('\n(press enter)\n');
            start = tic;
            while (toc(start) <= timeToRun)
                key = waitForResponseBox();
                if  key ~= 'none'
                    playSoundTest(P, ear, bMute)
                end
            end
            WaitSecs(0.1);

            continue

          case 'r'
            [eventTable, table_filename] = createTable(P, ...
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

            if P.bShowDisplay
                [P.window, P.xCenter, P.yCenter] = init_screen(P, 'fullscreen');
            end

            if P.bShowSmallDisplay
                [P.small_window, P.small_xCenter, P.small_yCenter] = ...
                    init_screen(P, 'small');
            end
            continue

          case 'u' % update values

            str = sprintf("enter new number of button presses, currently: %d\nnew value:", P.num_events_per_block);
            newNumEvents = str2double(input(str, 's'));
            P.num_events_per_block = newNumEvents;
            continue

          otherwise
            continue

        end % end switch-case

        %% run the chosen condition
        [eventTable, shuffled_conditions, outP] = ...
            single_run(P, eventTable);

        T = splitvars(table(arrayfun(@index_to_name, shuffled_conditions)));
        T.Properties.VariableNames =  {'ear', 'hand'};
        log = outP.log;
        log.blockConditionsInOrder = T;
        log.blockStartTimes = P.block_start_times;
        log.instructionDisplayTimes = P.instruction_display_times;
        log.blockEndTimes = P.block_end_times;

        WaitSecs(0.1);

        save(fullfile(P.output_dir, table_filename), "eventTable");
        save(fullfile(P.output_dir, table_filename + "_log"), "log");
        writetable(eventTable, fullfile(P.output_dir, table_filename + ".xls"));

        clear eventTable
        fprintf("******\n  Done!\n******\n\n")

    catch E
        ListenChar(1) % enable listening for chars and output to console
        msgText = getReport(E,'basic');
        fprintf("Caught exception: %s\n", msgText)
        if P.debugOn
            PsychPortAudio('Close',P.pahandle);
            sca
            rethrow(E)
        end
    end % end try/catch
end % end while(true)


PsychPortAudio('Close',P.pahandle);

% end slide
WaitSecs(0.1);
instruction = imread('thank_you_end.JPG');
display_image(P, instruction);


% wait for a key press in order to continue
ListenChar(1) % enable listening for chars and output to console
RestrictKeysForKbCheck([]);
fprintf("Press any key to continue\n");
KbWait;
sca;

