
function splitEventTable(T, affector, prefix, output_dir, fields_to_keep)
    L_ear_idx = T.ear == 'L';
    R_ear_idx = T.ear == 'R';
    L_hand_idx = T.hand == 'L';
    R_hand_idx = T.hand == 'R';

    if isequal(affector, 'ear')
        L_filter = L_ear_idx;
        R_filter = R_ear_idx;
    elseif isequal(affector, 'hand')
        L_filter = L_hand_idx;
        R_filter = R_hand_idx;
    end

    filtered_rows_L = array2table(T{L_filter, :}, ...
                            'VariableNames',T.Properties.VariableNames);
    filtered_rows_R = array2table(T{R_filter, :}, ...
                            'VariableNames',T.Properties.VariableNames);
    filtered_rows_L = filtered_rows_L(:, fields_to_keep);
    filtered_rows_R = filtered_rows_R(:, fields_to_keep);

    file_name_L = sprintf("%s_%s_%s.mat", prefix, "L", affector);
    file_name_R = sprintf("%s_%s_%s.mat", prefix, "R", affector);
    save(fullfile(output_dir, file_name_L), "filtered_rows_L");
    save(fullfile(output_dir, file_name_R), "filtered_rows_R");

    file_name_L = sprintf("%s_%s_%s.csv", prefix, "L", affector);
    file_name_R = sprintf("%s_%s_%s.csv", prefix, "R", affector);
    save(fullfile(output_dir, file_name_L), "filtered_rows_L");
    save(fullfile(output_dir, file_name_R), "filtered_rows_R");
end
