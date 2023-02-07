function [conditionOrder,runOrder] = setConditionOrder(params)

switch params.demographics.order
    case 1
        conditionOrder = {[repmat(1,1,params.runsOfEach),repmat(2,1,params.runsOfEach),repmat(3,1,params.runsOfEach-1)],[repmat(1,1,params.runsOfEach),repmat(2,1,params.runsOfEach)]};
        runOrder = {[1:8],[1:6]};
    case 2
        conditionOrder = {[repmat(1,1,params.runsOfEach),repmat(2,1,params.runsOfEach),repmat(3,1,params.runsOfEach-1)],[repmat(2,1,params.runsOfEach),repmat(1,1,params.runsOfEach)]};;
        runOrder = {[1:8],[4:6,1:3]};
    case 3
        conditionOrder = {[repmat(2,1,params.runsOfEach),repmat(1,1,params.runsOfEach),repmat(3,1,params.runsOfEach-1)],[repmat(1,1,params.runsOfEach),repmat(2,1,params.runsOfEach)]};
        runOrder = {[4:6,1:3,7:8],[1:6]};
    case 4
        conditionOrder = {[repmat(2,1,params.runsOfEach),repmat(1,1,params.runsOfEach),repmat(3,1,params.runsOfEach-1)],[repmat(2,1,params.runsOfEach),repmat(1,1,params.runsOfEach)]};
        runOrder = {[4:6,1:3,7:8],[4:6,1:3]};
end