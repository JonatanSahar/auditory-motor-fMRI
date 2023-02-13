function correct = isCorrectKey(key, hand)
    correct = (key == 'b' && hand == 'R') || (key == 'r' && hand == 'L')
end
