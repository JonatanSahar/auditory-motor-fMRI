
function get_conditions(cond1, cond2, repeat_times)
    [X, Y] = meshgrid(cond1, cond2);
    condition_pairs = [X(:), Y(:)];
    assert(mod(num_blocks, length(condition_pairs)) == 0);
    conditions = repmat(condition_pairs, repeat_times, 1);

end
