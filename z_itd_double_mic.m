%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% Ambient Noise Calibration %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% if the noise calibration parameter doesnt exist, do a silent room
% calibration
if exist('noise_calib','var') == 0
    rec = dsp.AudioRecorder('OutputNumOverrunSamples',true,'SampleRate',44100,'NumChannels',2);
    disp('Calibrating, please keep silent');
    audio = [];    
    % start the loop 
    tic;
    while toc < 5  
      [audioIn,nOverrun] = step(rec);
      audio = [audio ;audioIn];

          if nOverrun > 0
            fprintf('Audio recorder queue was overrun by %d samples\n'...
                ,nOverrun);
          end
    end
    noise_calib = max(max(audio));
    release(rec);
    disp('Calibration complete'); 
    pause(0.3);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Main Loop %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot the angle estimation of the sound source
figure(3);
angle = linspace(0,pi,200);
plot(cos(angle), sin(angle), 'k-');
axis([-1.5 1.5 0 1.5]);
xlabel('X axis');
ylabel('Y axis');
hold on;

% initialize
rec = dsp.AudioRecorder('OutputNumOverrunSamples',true,'SampleRate',44100,'NumChannels',2);
%AFW = dsp.AudioFileWriter('myspeech.wav','FileFormat', 'WAV');
disp('Speak into microphone now');
angle = [];
audio = [];
prev_angle = 0;
angleHandle = plot(sin(0), cos(0),'ro', 'MarkerSize', 15);  

% start the loop 
tic;
prev_t = toc;
while toc < 10  
  [audioIn,nOverrun] = step(rec);
  audio = [audio ;audioIn];
  %step(AFW,audioIn);
  angle(end+1)= z_itd(audioIn, noise_calib);
  % plot the angle position on the unit circle every 0.1 seconds
  if toc-prev_t > 0.1
      delete(angleHandle);
      angleHandle = plot(sin(angle(end)), cos(angle(end)),'ro', 'MarkerSize', 15);  
      drawnow
      prev_t = toc;
  end

  
%   % avoid noise causing angle jumps
%   if abs(prev_angle-angle(end)) > 10
%       angle(end) = prev_angle;
%   end
%   prev_angle = angle(end);
  
  %disp(angle);
  if nOverrun > 0
    fprintf('Audio recorder queue was overrun by %d samples\n', nOverrun);
  end
end
release(rec);
%release(AFW);
disp('Recording complete'); 
hold off;

%% 
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

