function getSubjectOrder()

prompt = {'insert subject number or order:'};
dlg_title = 'Suject Data';
num_lines = 1;
def = {''};
answer = inputdlg(prompt,dlg_title,num_lines,def);
subject=(answer{1});

outDir=fullfile('.','dataFiles',subject);

if str2double(subject)>100

    if ~exist(outDir)
        disp('no data for this subject!')
    else
        load(fullfile(outDir,[subject,'Session1Run1.mat']),'params')
    end

elseif any(str2double(subject) == 1:4)
    params.runsOfEach=3;
    params.demographics.order = str2double(subject); 
    [params.conditionOrder params.runOrder] = setConditionOrder(params);
end

disp(params.conditionOrder);


