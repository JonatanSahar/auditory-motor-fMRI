
function splitEventMatrix(M, prefix, output_dir)
    for ear = [1 2]
        for hand = [1, 2]
            filtered_rows = M((M(:,2) == ear) & (M(:,3) == hand), :)

            file_str = sprintf("%s_%s_%s.mat", prefix, index_to_name(ear) index_to_name(hand));
            save(fullfile(output_dir, file_str), "filtered_rows");
        end
    end
end
