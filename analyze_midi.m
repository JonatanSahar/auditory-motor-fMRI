%% Analyze Data
% for now only measure intervals between subject's presses in each
% block/test/retention

clc; clear;

%% Define Parameters
num_blocks = 20;
num_test_blocks = 4;
sequence = [72, 74, 76, 77, 79, 77, 76, 74];
seq_len = length(sequence); 
seq_per_block = 5; %number of sequences in block
block_len = (seq_len * seq_per_block + 1) * 2;
% IPI = 0.35;
% note_duration = 0.1;

%% Create Results Table
% access files and extract number of subjects
xl_path = fullfile(pwd, 'midi_data');
xl_files = dir(fullfile(xl_path, '*.xls'));
num_files = length(xl_files);

%% Orgenaize files in folders
for i_file = 1 : num_files
    filename = xl_files(i_file).name;
    % get details
    file_details = strsplit(filename, {'_', '.'});
    subj_num = str2double(file_details{1});
    subj_folder = fullfile(xl_path, strcat('sub_', subj_num));
    if ~exist(subj_folder, dir)
        mkdir(subj_folder);
    end
end

%% create table
sub_folders = dir(xl_path);
num_subjects = length(sub_folders) - 2;

% create table
[results_table, res_table_name] = createResultsTable(num_blocks, num_test_blocks, num_subjects);

%% Loop files
for i_folder = 3 : num_subjects + 2
    folder_name = sub_folders(i_folder).name;
    file_lst = dir(fullfile(xl_path, folder_name, '*.xls'));
    num_files = length(file_lst);
    
    for i_file = 1 : num_files
        filename = file_lst(i_file).name;
        % get details
        file_details = strsplit(filename, {'_', '.'});
        subj_num = str2double(file_details{1});
        phase = file_details{3}; 
        switch file_details{2}
            case 'LH-RE'
                condition = 1;
            case 'LH-LE'
                condition = 2;
            case 'RH-RE'
                condition = 3;
            case 'RH-LE'
                condition = 4;
            otherwise
                fprintf("Warning: wrong condition for subject %d.\n", subj_num);
        end
        res_row = i_folder - 2;
        
        % enter details to result table
        results_table.subject_number(res_row) = subj_num;
        results_table.condition(res_row) = condition;
        
        % import excel file
        if ~strcmp(phase, 'trial')
            data_table = readtable(fullfile(xl_path, folder_name, filename));
        else
            continue;
        end

        switch phase
            case 'train'
                col_idx = 3;
            case 'pre'
                col_idx = 3 + num_blocks * 3;
            case 'post'
                col_idx = 3 + num_blocks * 3 + num_test_blocks * 3;
            case 'retention'
                col_idx = 3 + num_blocks * 3 + num_test_blocks * 6;
            otherwise
                fprintf("Warnning: wrong phase for subject %d.\n", subj_num);
        end
        
        % extract time stamps of each block
        IPI_vec = [];
        noteD_vec = [];
        for i_row = 1 : 2 : height(data_table) - 1
            error_cnt = 0;
            if i_row ~= height(data_table) - 1
                if (data_table.block(i_row) == data_table.block(i_row + 2)) 
                    curr_note = data_table.note(i_row);
                    nxt_note = data_table.note(i_row + 2);
                    if (~isempty(strfind(sequence, [curr_note, nxt_note])) || ...
                            ~isempty(strfind([74, 72], [curr_note, nxt_note]))) 
                        % calculate IPI
                        IPI_vec(end + 1) = data_table.time_stamp(i_row + 2) - data_table.time_stamp(i_row);
                        % calculate note duration
                        noteD_vec(end + 1) = data_table.time_stamp(i_row + 1) - data_table.time_stamp(i_row);
                    else
                        error_cnt = error_cnt + 1;
                    end
                else
                    % calculate medians
                    IPI_med = median(IPI_vec)*1000;
                    noteD_med = median(noteD_vec)*1000;

                    % enter to results table
                    curr_block = data_table.block(i_row);
                    results_table(res_row, col_idx + (curr_block - 1)*3) = {IPI_med};
                    results_table(res_row, col_idx + (curr_block - 1)*3 + 1) = {noteD_med};
                    results_table(res_row, col_idx + (curr_block - 1)*3 + 2) = {error_cnt};
                end
            else
                % calculate medians
                IPI_med = median(IPI_vec)*1000;
                noteD_med = median(noteD_vec)*1000;

                % enter to results table
                curr_block = data_table.block(i_row);
                results_table(res_row, col_idx + (curr_block - 1)*3) = {IPI_med};
                results_table(res_row, col_idx + (curr_block - 1)*3 + 1) = {noteD_med};
                results_table(res_row, col_idx + (curr_block - 1)*3 + 2) = {error_cnt};
            end
        end
    end
end

%% Export Results Table to Excel
% path to excel files
res_path = fullfile(pwd);
% export
writetable(results_table, fullfile(res_path, res_table_name));


%% %%%%%%%%%%%%%%%%%%%%%%%% Auxiliary Functions %%%%%%%%%%%%%%%%%%%%%%%% %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% allocate an empty table to hold all subjects' results in
function [results_table, filename] = createResultsTable(num_blocks, num_test_blocks, num_subjects)
    parameters = cell(1, 2 + num_blocks * 3 + 3 * num_test_blocks * 3);
    parameters{1,1} = 'subject_number'; 
    parameters{1,2} = 'condition';
    for i_block = 3 : 3 : num_blocks * 3 
        parameters{i_block} = strcat('block_', num2str(i_block / 3), '_IPI');
        parameters{i_block + 1} = strcat('block_', num2str(i_block / 3), '_noteD');
        parameters{i_block + 2} = strcat('block_', num2str(i_block / 3), '_numErorrs');
    end
    for i_test_block = 3 + num_blocks * 3 : 3 : num_blocks * 3 + num_test_blocks * 3
        parameters{i_test_block} = strcat('pre-test_', num2str(i_test_block / 3), '_IPI');
        parameters{i_test_block + 1} = strcat('pre-test_', num2str(i_test_block / 3), '_noteD');
        parameters{i_test_block + 2} = strcat('pre-test_', num2str(i_test_block / 3), '_numErorrs');
    end
    for i_test_block = 3 + num_blocks * 3 + num_test_blocks * 3 : 3 : num_blocks * 3 + num_test_blocks * 3 + num_test_blocks * 3
        parameters{i_test_block} = strcat('post-test_', num2str(i_test_block / 3), '_IPI');
        parameters{i_test_block + 1} = strcat('post-test_', num2str(i_test_block / 3), '_noteD');
        parameters{i_test_block + 2} = strcat('post-test_', num2str(i_test_block / 3), '_numErorrs');
    end
    for i_test_block = 3  + num_blocks * 3 + 2 * 3 * num_test_blocks : 3 : num_blocks * 3 + 2 * 3 * num_test_blocks + num_test_blocks * 3
        parameters{i_test_block} = strcat('retention_', num2str(i_test_block / 3), '_IPI');
        parameters{i_test_block + 1} = strcat('retention_', num2str(i_test_block / 3), '_noteD');
        parameters{i_test_block + 2} = strcat('retention_', num2str(i_test_block / 3), '_numErorrs');

    end
    
    var_types = cell(1, length(parameters));
    for i_column = 1 : length(parameters)
        var_types{i_column} = 'double';
    end

    table_size = [num_subjects, length(parameters)];
    results_table = table('Size',table_size, 'VariableTypes', var_types, 'VariableNames', parameters);
    filename = 'results.xls';
end
