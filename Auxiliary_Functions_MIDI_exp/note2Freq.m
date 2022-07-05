% determine frequency based on the pressed note
function freq = note2Freq(note)
    freqA = 440;
    noteA = 69;
    freq = freqA * 2.^((note-noteA)/12);
end