% 
% record_time = 20;
% % start recording
% rec = audiorecorder(44100,16,2);
% record(rec, record_time);
% %fprintf('       ');
% angle = 0;
% prev = 1;
% i=0;
% while strcmp(rec.Running, 'on')
%     % while recording, shoot the online data to the buffer
%     pause(0.1);
% %     pause(rec);
%     % use itd to deal with the buffer
%     data = getaudiodata(rec);
%     data = data(prev:end,:);
%     [prev,~] = size(data);
%     angle = itd(data);
%     resume(rec);
%     % display online results
%     %fprintf('\b\b\b\b\b\b\b%-7s',num2str(angle));
%     disp(angle);
%     %i=i+1;
% end
% fprintf('\n');

AR = dsp.AudioRecorder('OutputNumOverrunSamples',true,'SampleRate',44100,'NumChannels',2);
%AFW = dsp.AudioFileWriter('myspeech.wav','FileFormat', 'WAV');
disp('Speak into microphone now');
angle = [];
tic;
while toc < 10
  
  [audioIn,nOverrun] = step(AR);
  %step(AFW,audioIn);
  %angle = step(@itd, audioIn);
  angle= itd(audioIn);
  disp(angle);
  if nOverrun > 0
    fprintf('Audio recorder queue was overrun by %d samples\n'...
        ,nOverrun);
  end
end
release(AR);
release(AFW);
disp('Recording complete'); 
