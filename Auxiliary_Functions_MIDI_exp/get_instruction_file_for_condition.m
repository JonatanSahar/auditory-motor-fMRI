
function file = get_instruction_file_for_condition(cond)
    fprintf("jonathan")
    ear = cond(1)
    hand = cond(2)
    if ear == "none" % = motor localizer
        if hand == "R"
            file = 'use_R.JPG';
        elseif hand == "L"
            file = 'use_L.JPG';
        end
    % since hand ~=none, it's an audiomotor run
    elseif ear == "R"
        file = 'play_R.JPG';
    elseif ear == "L"
        file = 'play_L.JPG';
    end
end
