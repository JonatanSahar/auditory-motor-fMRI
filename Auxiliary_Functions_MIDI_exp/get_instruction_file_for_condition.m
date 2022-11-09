
function file = get_instruction_file_for_condition(cond)
    ear = cond(1)
    hand = cond(2)

    file = sprintf('%s.JPG', hand);
end

%     if ear == "none" % = motor localizer
%         if hand == "R"
%             file = 'use_R.JPG';
%         elseif hand == "L"
%             file = 'use_L.JPG';
%         end
%     % since ear ~=none, it's an audiomotor run
%     elseif hand == "R"
%         file = 'play_R.JPG';
%     elseif hand == "L"
%         file = 'play_L.JPG';
%     end
% end
