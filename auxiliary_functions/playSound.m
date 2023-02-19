function playSound(P, ear, bMute)
    fprintf("ding!\n")
if ~exist('bMute','var')
    bMute = false;
end
     if ~bMute
        if strcmp(ear, 'R')
            PsychPortAudio('FillBuffer',P.pahandle,P.sound.right);
        elseif strcmp(ear, 'L')
            PsychPortAudio('FillBuffer',P.pahandle,P.sound.left);
        elseif strcmp(ear, 'both')
            PsychPortAudio('FillBuffer',P.pahandle,P.sound.wavedata);
        end

    else
        PsychPortAudio('FillBuffer',P.pahandle,P.sound.silence);
    end
    PsychPortAudio('Start',P.pahandle); % optionally play a fraction of the sound: , 0.3);
    WaitSecs(P.soundDuration);
    PsychPortAudio('Stop',P.pahandle);
end
