% assign group name according to the assigned condition
% 1 = LH-LE, 2 = LH-RE)
function group_name = subjectsGroup(group)
    switch group
        case 1
            group_name = 'LE';
        case 2
            group_name = 'RE';
        otherwise
            error('Error: no such group number.\n');
    end
end