function playSound(P, ear, bMute)
    fprintf("ding!")
    return

    pahandle2 = PsychPortAudio('Open',[],[],P.tm,P.sound.freq,P.nrchannels);
    PsychPortAudio('FillBuffer',pahandle2,P.sound.wavedata);

    PsychPortAudio('Start',pahandle2);
    pause(0.2);
    PsychPortAudio('Close',pahandle2);
    % if bMute
    %     dev_writer(mute_waveform);
    % else
    %     if strcmp(ear, 'R')
    %         dev_writer([mute_waveform, osc()]);
    %     elseif strcmp(ear, 'L')
    %         dev_writer([osc(), mute_waveform()]);
    %     elseif strcmp(ear, 'both')
    %         dev_writer(osc());
    %     end
    % end
end
