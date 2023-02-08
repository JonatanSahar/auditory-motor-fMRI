% allocate an empty data table to hold experiment's current phase details 
function [data_table, filename] = createMidiTable(p, table_name, suffix)
    num_lines = p.num_blocks * p.sequence_len * 2; % x2 for note On and Off messages
    table_size = [num_lines, length(p.parameters)];
    % table_size = [p.num_runs * num_lines_per_block, length(p.parameters)];
    data_table = table('Size',table_size, 'VariableTypes', p.var_types, 'VariableNames', p.parameters);
    % group_name = subjectsGroup(group);
    filename = sprintf("%d_%s(%s).xls", p.subject_number, table_name, suffix);
end
