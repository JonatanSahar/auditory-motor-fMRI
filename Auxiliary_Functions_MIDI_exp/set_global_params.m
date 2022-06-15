function params = set_global_params(params)
params.seed='shuffle';
rng(params.seed);
params.expName='buttonPress2020';
%% Experiment length and order
params.numBlocks=1;
params.numTrials=1
params.ITI=1;
%% Subject Specific Data
prompt = {'Subject number','age','gender','modality','order'};
dlg_title = 'Suject Data';
def = {'','','1- male 2- female','1- auditory 2- visual','1-4 - generator first 5-8 - follower first'};
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines,def);
outName=[answer{1},'_',params.expName,'.mat'];
%% check subject parameters
ok=0;
while ~ok
    ok=1;
    def={answer{1},answer{2},answer{3},answer{4},answer{5}};
    if str2num(answer{4})==1
        params.outputDir='./results_auditory';
        outName=[answer{1},'_',params.expName,'Auditory.mat'];
    else
        params.outputDir='./results_visual';
        outName=[answer{1},'_',params.expName,'Visual.mat'];
    end
    if ~exist(params.outputDir)
        mkdir(params.outputDir)
    end
    if exist(fullfile(params.outputDir,outName))&&str2num(answer{1})~=99
        prompt{1}='Subject already exsits, enter a different subject number:';
        ok=0;
    end
    if str2num(answer{3})<1 || str2num(answer{3})>2
        prompt{3}='Invalid gender. 1- male 2- female';
        ok=0;
    end
    if str2num(answer{4})<1 || str2num(answer{4})>2
        prompt{4}='Invalid modality. Auditory- 1 Visual- 2';
        ok=0;
    end
    if str2num(answer{5})<1 || str2num(answer{5})>8
        prompt{5}='Invalid order. 1-4 - generator first 5-8 - follower first';
        ok=0;
    end
    if ~ok
        answer= inputdlg(prompt,dlg_title,num_lines,def);
    end
end
%% save subject params
params.subjectNumber=answer{1};
params.age=answer{2};
params.gender=answer{3};
params.modality=str2num(answer{4});
params.order=str2num(answer{5});
params.outName=fullfile(params.outputDir, outName);

%% set trial order
% 1-4 generator; 5-8 - follower
% SL- right finger soft; LS - right fingre loud
% 1 - gLS gSL fLS fSL; 2 - gLS gSL fSL fLS;
% 3 - gSL gLS fLS fSL; 4 - gSL gLS fSL fLS;
% 5 - fSL fLS gSL gLS; 6 - fSL fLS gLS gSL;
% 7 - fLS fSL gSL gLS; 8 - fLS fSL gLS gSL;

switch params.order
    case 1
        params.blockOrder=1:4;
    case 2
        params.blockOrder=[1,2,4,3];
    case 3
        params.blockOrder=[2,1,3,4];
    case 4
        params.blockOrder=[2,1,4,3];
    case 5
        params.blockOrder=[3,4,1,2];
    case 6
        params.blockOrder=[3,4,2,1];
    case 7
        params.blockOrder=[4,3,1,2];
    case 8
        params.blockOrder=4:-1:1;     
end
params.mapping=[1,2;2,1;1,2;2,1];
params.followerOrder=Shuffle(repmat([1,2],2*params.numBlocks,params.numTrials)')';


