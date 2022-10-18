function [ear, hand] = get_condition_for_block(conditions, i_block)
    ear = index_to_name(conditions(i_block, 1));
    hand = index_to_name(conditions(i_block, 2));
end

