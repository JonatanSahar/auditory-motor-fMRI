% allocate an empty data table to hold experiment's current phase details 
function [data_table, filename] = createTable(p, table_name, suffix)
    table_size = [p.num_blocks, length(p.parameters)];
    data_table = table('Size',table_size, 'VariableTypes', p.var_types, 'VariableNames', p.parameters);
    filename = sprintf("%d_%s_%s", p.subject_number, table_name, suffix);
end
