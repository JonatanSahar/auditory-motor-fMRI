function params=backgroundData()
params.runsOfEach = 3;
params.numRuns=[params.runsOfEach * 3 - 1, params.runsOfEach * 2 ];
params.blockTypes={[1,2,3],[1,2]};
%% First prompt getting ID
prompt = {'Subject:'};
dlg_title = 'Suject Data';
num_lines = 1;
def = {''};
answer = inputdlg(prompt,dlg_title,num_lines,def);
params.subject=(answer{1});

params.outDir=fullfile('.','dataFiles',params.subject);

if ~exist(params.outDir)
    mkdir(params.outDir);
end


%% second prompt - get demographics info if does not exist
if ~exist(fullfile(params.outDir,[params.subject,'_demographics.mat']))
    prompt = {'Age:','Gender:','Order:'};
    num_lines = 1;
    def = {'','1- Male 2- Female','1-4'};
    answer = inputdlg(prompt,dlg_title,num_lines,def);

    ok=0;
    while ~ok
        ok=1;
        def={answer{1},answer{2},answer{3}};
        prompt = {'Age:','Gender:','Order:'};

        if str2double(answer{2}) ~= 1 && str2double(answer{2}) ~= 2
            prompt{2}='Invalid Gender! 1- Male 2- Female';
            ok=0;
        end

        if str2double(answer{3}) < 1 || str2double(answer{3}) > 4
            prompt{3}='Invalid Order! 1-12';
            ok=0;
        end

        if ~ok
            answer= inputdlg(prompt,dlg_title,num_lines,def);
        end

    end
    demographics.age=str2double(answer{1});
    demographics.gemder=str2double(answer{2});
    demographics.order=str2double(answer{3});
    save(fullfile(params.outDir,[params.subject,'_demographics.mat']),'demographics');
else
    load(fullfile(params.outDir,[params.subject,'_demographics.mat']));
end
    params.demographics = demographics;
    clear demographics

%% 3rd promt
prompt = {'Session type:','Run number:','training:','Use eyetracker?'};
num_lines = 1;
if isempty(dir([params.outDir,'\',params.subject,'Session2*'])) && ~exist([params.outDir,'\',params.subject,'Session1Run',num2str(params.numRuns(1)),'.mat'])
    def{1} = '1';
else
    def{1} = '2';
end

if isempty(dir([params.outDir,'\',params.subject,'Session',num2str(def{1}),'*']))
    def{2}='1';
else
    d            = dir([params.outDir,'\',params.subject,'Session',num2str(def{1}),'*']);
    [~, index]   = max([d.datenum]);
    youngestFile = fullfile(d(index).folder, d(index).name);
    def{2} = num2str(str2num(youngestFile(end-4))+1);
end

def{3} = '0 - no 1 - yes';
def{4}=def{3};
answer = inputdlg(prompt,dlg_title,num_lines,def);
params.sessionType=str2num(answer{1});
params.runNum=str2num(answer{2});
params.training=str2num(answer{3});
params.eyetracker=str2num(answer{4});
ok=0;
while ~ok
    ok=1;
    def={answer{1},answer{2},answer{3},answer{4}};
    prompt = {'Session type:','Run number:','training:','Use eyetracker?'};

    if params.sessionType~=1 && params.sessionType ~= 2
        prompt{1}='Invalid value! 1-localizers 2-Task';
        ok=0;
    end

    if exist([params.outDir,'\',params.subject,'Session',num2str(params.sessionType),'Run',num2str(params.runNum),'.mat']) && params.training == 0
        answer = questdlg('Subject and Run Number already exist! Override the file?', ...
        	'override run', ...
        	'Yes','No','No');
        if strcmp(answer,'No')
            ok=0;
            prompt{2}='enter new run number';
        end
    end
    if params.training<0 || params.training>1
        prompt{3}='Invalid value! 0 - no 1 - yes';
        ok=0;
    end

    if params.runNum<0 || ((params.sessionType==1 && params.runNum>8) || (params.sessionType==2 && params.runNum>6))
        prompt{2}='Invalid run! Session1: 1-8 Session2: 1-6';
        ok=0;
    end

    if params.eyetracker ~= 0 && params.eyetracker ~=1
        prompt{4}='Invalid value! 0 - no 1 - yes';
        ok=0;
    end

    if ~ok
        answer= inputdlg(prompt,dlg_title,num_lines,def);
        params.sessionType=str2num(answer{1});
        params.runNum=str2num(answer{2});
        params.training=str2num(answer{3});
        params.eyetracker=str2num(answer{4});
    end
end

%% constant variables
params.conditions = {{'Motor_Only','Auditory_Only','Visual_Localizer'},{'Motor_cues','Auditory_cues'}};
params.run_nums = [1:3,1:3,1:2];
params.countCatch{1}=[0,0,0,2,2,4,3,1];
params.countCatch{2}=[4,2,2,2,4,2];

%% experiment timing
params.DispTime=0.4; %% down from 0.5 in first pilot
params.delayTime=0.6;
params.instTime=1;
params.eventTime=1.8;
params.eventsPerBlock=5; %% changed from 6 in first plot to get a better RT time for active condition
params.timeBetweenBlocks=8;

params.blocksPerRun=16;

params.blocksPerRunPractice=4;
params.numRunsPractice=2;
params.blockDuration=params.eventsPerBlock*params.eventTime+params.timeBetweenBlocks+params.instTime;
params.TR=1;
%%%%%%
params.seed = 'shuffle';
%% display parameters
params.fixCrossDim = 20; %size of fixation cross in pixels
params.FixationCoords = [[-params.fixCrossDim params.fixCrossDim 0 0]; [0 0 -params.fixCrossDim params.fixCrossDim]];%setting fixation point coordinations
params.lineWidthFixation = 4; %line width of fixaton cross in pixels
params.fixationColorGo = [0,1,0];
params.fixationColorRest = [1,1,1];
params.StimDim=[0 0 185 185]; %Set Stimulus Dimantions [top-left-x, top-left-y, bottom-right-x, bottom-right-y].
params.textSize = 54;

%% sounds
[params.sound.y,params.sound.freq]=audioread('./sound.wav');
params.sound.wavedata{1}=[zeros(size(params.sound.y'));params.sound.y']; %% only right ear feedback
params.sound.wavedata{2}=[params.sound.y';zeros(size(params.sound.y'))]; %% only left ear feedback
[params.odd.y,params.odd.freq]=audioread('./odd.wav');
params.sound.wavedata{3}=[zeros(size(params.sound.y')); params.odd.y']; %% odd to right ear feedback
params.sound.wavedata{4}=[params.odd.y';zeros(size(params.sound.y'))]; %% odd to left ear feedback

params.volume = 10;

%% create trial order
[params.conditionOrder params.runOrder] = setConditionOrder(params);
disp(params.conditionOrder);
if params.sessionType == 1
    orderFile = [params.outDir,'\trialOrder_Session1.mat'];
else
    orderFile = [params.outDir,'\trialOrder_Session2.mat'];
end

if ~exist(orderFile)
    if ~exist(params.outDir, 'dir')
        mkdir(params.outDir);
    end
    trialOrder=createTrialOrder(params);
    save(orderFile,'trialOrder');  
    clear trialOrder;
end


if params.training
    if params.sessionType==1 && params.conditionOrder{1}(params.runNum) == 1
        params.trialOrder = zeros(params.blocksPerRunPractice*params.eventsPerBlock,1);
        params.trialOrder(:,:,2) = [zeros(params.eventsPerBlock,1);ones(params.eventsPerBlock*2,1);zeros(params.eventsPerBlock,1)];
        params.trialOrder(:,:,3) = repmat(params.conditionOrder{params.sessionType}(params.runNum),size(params.trialOrder(:,:,1)));
    else
        params.trialOrder = zeros(params.blocksPerRunPractice*params.eventsPerBlock,1);
        if params.sessionType==1
            params.trialOrder([3,17])=1;
        else
            params.trialOrder([6,16])=1;
        end
        params.trialOrder(:,:,2) = [zeros(params.eventsPerBlock,1);ones(params.eventsPerBlock*2,1);zeros(params.eventsPerBlock,1)];
        params.trialOrder(:,:,3) = repmat(params.conditionOrder{params.sessionType}(params.runNum),size(params.trialOrder(:,:,1)));
    end
else
    load(orderFile);
    params.trialOrder = trialOrder(:,params.runNum,:);
    clear trialOrder;
end