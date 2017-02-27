% Record and save own voice
recObj = audiorecorder(16000,16,1);
disp('Start Speaking.');
recordblocking(recObj, 5); % Record this sentence within 5 seconds
disp('End of Recording.');
play(recObj); % Listen to what has been recorded
y = getaudiodata(recObj);
plot(y); % Have a look at waveform
audiowrite('own_voice.wav',y,16000); % Write to a file
