function playSound(P, ear, bMute)
    fprintf("ding!\n")
    pahandle = PsychPortAudio('Open',[],[],P.latenceyReq,[],P.nrchannels);

    if ~exist('bMute','var') || ~bMute
        if strcmp(ear, 'R')
            PsychPortAudio('FillBuffer',pahandle,P.sound.right);
        elseif strcmp(ear, 'L')
            PsychPortAudio('FillBuffer',pahandle,P.sound.left);
        elseif strcmp(ear, 'both')
            PsychPortAudio('FillBuffer',pahandle,P.sound.wavedata);
        end

    else
        PsychPortAudio('FillBuffer',pahandle,P.sound.silence);
    end
    PsychPortAudio('Start',pahandle);
    WaitSecs(0.4);
    PsychPortAudio('Close',pahandle);
end
