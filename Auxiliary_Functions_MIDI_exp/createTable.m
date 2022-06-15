% allocate an empty data table to hold experiment's current phase details 
function [data_table, filename] = createTable(...
    num_blocks, num_lines_per_block, parameters, var_types, subject_number, table_name, group)
    table_size = [num_blocks, length(parameters)];
    % table_size = [num_blocks * num_lines_per_block, length(parameters)];
    data_table = table('Size',table_size, 'VariableTypes', var_types, 'VariableNames', parameters);
    group_name = subjectsGroup(group);
    filename = strcat(num2str(subject_number), '_', group_name, '_', table_name, '.xlsx');
end
