function correct = isCorrectKey(key, hand)
    correct = (isequal(key, 'r') && isequal(hand,'R')) || (isequal(key,'b') && isequal(hand,'L'));
end

