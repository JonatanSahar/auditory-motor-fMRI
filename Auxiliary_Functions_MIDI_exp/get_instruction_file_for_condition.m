
function file = get_instruction_file_for_condition(cond)
    ear = cond(1);
    hand = cond(2);
    if cond == ["R" "R"]
        file = 'instructions_RR.jpg';
    elseif cond == ["R" "L"]
        file = 'instructions_RL.jpg';
    elseif cond == ["L" "R"]
        file = 'instructions_LR.jpg';
    elseif cond == ["L" "L"]
        file = 'instructions_LL.jpg';
    elseif cond == ["none" "R"]
        file = 'instructions_motor_only_R.jpg';
    elseif cond == ["none" "L"]
        file = 'instructions_motor_only_L.jpg';
    elseif cond == ["R" "none"]
        file = 'instructions_auditory_only_R.jpg';
    elseif cond == ["L" "none"]
        file = 'instructions_auditory_only_L.jpg';
    
    end
    

end
