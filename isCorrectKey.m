function correct = isCorrectKey(key, hand)
    correct = (isequal(key, 'b') && isequal(hand,'R')) || (isequal(key,'r') && isequal(hand,'L'))
end

