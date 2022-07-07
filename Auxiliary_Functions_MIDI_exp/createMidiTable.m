% allocate an empty data table to hold experiment's current phase details 
function [data_table, filename] = createMidiTable(...
    num_runs, num_blocks, sequence_len, parameters, var_types, subject_number, table_name)
    num_lines = num_runs * num_blocks * sequence_len * 2; % x2 for note On and Off messages
    table_size = [num_lines, length(parameters)];
    % table_size = [num_runs * num_lines_per_block, length(parameters)];
    data_table = table('Size',table_size, 'VariableTypes', var_types, 'VariableNames', parameters);
    % group_name = subjectsGroup(group);
    filename = strcat(num2str(subject_number), '_', table_name, '.xlsx');
end
