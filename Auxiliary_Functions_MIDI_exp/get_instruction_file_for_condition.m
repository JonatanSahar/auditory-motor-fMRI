
function file = get_instruction_file_for_condition(cond)
    ear = cond(1);
    hand = cond(2);
    if cond == [1 1]
        file = 'instructions_RR.jpg';
    elseif cond == [1 2]
        file = 'instructions_RL.jpg';
    elseif cond == [2 1]
        file = 'instructions_LR.jpg';
    elseif cond == [2 2]
        file = 'instructions_LL.jpg';
    elseif cond == [0 1]
        file = 'instructions_motor_only_R.jpg';
    elseif cond == [0 2]
        file = 'instructions_motor_only_L.jpg';
    elseif cond == [1 0]
        file = 'instructions_auditory_only_R.jpg';
    elseif cond == [2 0]
        file = 'instructions_auditory_only_L.jpg';
    
    end
    

end
