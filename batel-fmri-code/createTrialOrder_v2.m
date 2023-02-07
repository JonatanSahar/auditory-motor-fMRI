function trialOrder_sorted=createTrialOrder_v2(params)
% This function gets the order of the experiment
% 1= MOTOR FIRST
% 2= AUDITORY FIRST
% This function returns the order of trails for a specific subject
% col- specific run
% first dim- catch trial (1 - yes, 0 - no)
% second dim- oprating hand (0 right 1 left)
% third dim- condition (0 motor 1 auditory)
rng(params.seed);

trailOrder=nan(params.blocksPerRun*params.eventsPerBlock,params.numRuns(params.sessionType),3);
for runn=1:params.numRuns(params.sessionType)
    handOrder=repmat([0,1],1,params.blocksPerRun/2);
%     if params.sessionType == 2
        bcatch=[zeros(1,params.blocksPerRun-params.countCatch{params.sessionType}(runn)),ones(1,params.countCatch{params.sessionType}(runn))];
%         if params.countCatch{params.sessionType}(runn) > 0
%             while sum(handOrder(bcatch==1))~=params.countCatch{params.sessionType}(runn)/2 && runn < 7
%                 bcatch=[0,Shuffle([zeros(1,params.blocksPerRun-params.countCatch{params.sessionType}(runn)-1),ones(1,params.countCatch{params.sessionType}(runn))])];
%             end
%         end
%     order = Shuffle(1:params.blocksPerRun);
%     handOrder=handOrder(order);
%     bcatch=bcatch(order);
    for block=1:params.blocksPerRun
        if ~bcatch(block)
            trailOrder(block*params.eventsPerBlock-params.eventsPerBlock+1:block*params.eventsPerBlock,runn,1)=0;
        else
            trailOrder(block*params.eventsPerBlock-params.eventsPerBlock+1:block*params.eventsPerBlock,runn,1)=[0,Shuffle([zeros(1,params.eventsPerBlock-2),1])];            
        end    
        trailOrder(block*params.eventsPerBlock-params.eventsPerBlock+1:block*params.eventsPerBlock,runn,2)=handOrder(block);
        trailOrder(:,runn,3)= params.conditionOrder{params.sessionType}(runn);
    end
end

%% sort by order of exp
trialOrder_sorted = trailOrder(:,params.runOrder{params.sessionType},1);
trialOrder_sorted(:,:,2) = trailOrder(:,params.runOrder{params.sessionType},2);
trialOrder_sorted(:,:,3) = trailOrder(:,:,3);
