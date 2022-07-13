function [ear, hand] = get_condition_for_block(shuffled_conditions, i_block)
    ear = index_to_name(shuffled_conditions(i_block, 1));
    hand = index_to_name(shuffled_conditions(i_block, 2));
end

