function [ear, hand] = get_condition_for_block(shuffled_conditions, i_block)
    ear = shuffled_conditions(i_block, 1);
    hand = shuffled_conditions(i_block, 2);
end

