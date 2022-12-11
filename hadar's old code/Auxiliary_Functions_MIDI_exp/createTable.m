% allocate an empty data table to hold experiment's current phase details 
function [data_table, filename] = createTable(...
    num_blocks, table_len, parameters, var_types, subject_number, phase, group)
    table_size = [num_blocks * table_len, length(parameters)];
    data_table = table('Size',table_size, 'VariableTypes', var_types, 'VariableNames', parameters);
    group_name = subjectsGroup(group);
    filename = strcat(num2str(subject_number), '_', group_name, '_', phase, '.xlsx');
end