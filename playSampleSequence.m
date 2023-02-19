
function playSampleSequence(P, ear)
%ear must be: 'L' or 'R, or 'both
    numSoundsInSample = 3;
    for i = 1:numSoundsInSample
        playSound(P, ear, false);
        WaitSecs(P.IPI);
    end
end
