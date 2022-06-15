 % convert right hand notes to be similar to left hand's
function note = convertHand(note)
    switch note
        case 48
            note = 79;
        case 50
            note = 77;
        case 52
            note = 76;
        case 53
            note = 74;
        case 55
            note = 72;
    end

end