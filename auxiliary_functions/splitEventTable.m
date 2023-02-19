
function splitEventTable(T, affector, output_name_prefix, output_dir)

    fields_to_keep = ["start_time",...
                      "play_duration",...
                      "weight"];

    % add a constant weight column
    T.weight = ones(length(T.ear), 1);

    idx.DISQ = T.error ~= 'none';
    idx.LE = T.ear == 'L' & T.error == 'none';
    idx.RE = T.ear == 'R' & T.error == 'none';
    idx.LH = T.hand == 'L' & T.error == 'none';
    idx.RH = T.hand == 'R' & T.error == 'none';


    if isequal(affector, 'ear')
        conditions = ['DISQ', "LE", 'RE']
    else
        conditions = ['DISQ', "LH", 'RH']
    end

    ear = T.ear(1);

    for cond = conditions
        table = array2table(T{idx.(cond), :},'VariableNames', T.Properties.VariableNames);
        table = table(:, fields_to_keep);

        if ear ~= "none"
            file_name = sprintf("%s_%sE_%s", output_name_prefix, ear, cond);
        else
            file_name = sprintf("%s_%s", output_name_prefix, cond);
        end

        save(fullfile(output_dir, file_name), "table");
        writetable(table, fullfile(output_dir, file_name), 'Delimiter','tab');

    end

end
