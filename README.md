# Event-based

function test()
clear

global fs; % sampling frequency
global c; % sound speed
c = 343; 

[src,fs] = audioread('human.wav');
src = src(:,(1));

% define room parameters
roomDim = [5    5    3];
src_loc = [4    1.5  0.1];
rcv_loc = [2.45  0.1   0.1;
           2.55  0.1   0.1;
           2.5   0.15  0.1];
num_rcv = size(rcv_loc,1); % number of receivers

% Make an initial guess for the location of the source.
guess = mean(rcv_loc, 1);
       
% distances between every pair of receivers
rcv_diff = [];
for i = 1:num_rcv
    for j = i+1:num_rcv
       rcv_diff(end+1) = distance(rcv_loc((i),:), rcv_loc((j),:));
    end
end

% run the room simulator and generate output waveforms for receivers
[SetupStruc] = ISM_setup(roomDim, src_loc, rcv_loc, fs);
RIR = fast_ISM_RIR_bank(SetupStruc,'fastISM_RIRs.mat');
dst = ISM_AudioData('fastISM_RIRs.mat',src);

% dst1 = dst(:,(1));
% dst2 = dst(:,(2));
% dst3 = dst(:,(3));

% calculate timelags between every pair of receivers
timelag = [];
for i = 1:num_rcv
    for j = i+1:num_rcv
       timelag(end+1) = cal_timelag(dst(:,(i)), dst(:,(j)), fs, rcv_diff);
    end
end



% angle1 = angle(X1);
% angle2 = angle(X2);
% 
% [mag_x1, idx1] = max(abs(X1));
% [mag_x2, idx2] = max(abs(X2));
% 
% px1 = angle(X1(1001));
% px2 = angle(X2(1001));

% w_k = 2*pi/length(X1)*1000;
%  d =SetupStruc.mic_pos((1),:) - SetupStruc.mic_pos((2),:);
%  d = sqrt(sum(d.*d));
% lag = px1-px2;

% %%%%%%%% using cross-correlation %%%%%%%%%
% [xc, lags]=xcorr(dst1,dst2);
% xc = abs(xc);
% [maxx,I]=max(xc);
% est_diff = lags(I)/fs*c;
% 
% while est_diff >= 0.1 
%     [maxx,I] = max(xc(xc<maxx));
%     timelag = lags(I)/fs;
%     est_diff = timelag*c;
% end
% 
% timelag = lags(I)/fs;
% est_diff = timelag*c
% real_distDiff = norm(SetupStruc.src_traj - SetupStruc.mic_pos((1),:)) ...
%     - norm(SetupStruc.src_traj - SetupStruc.mic_pos((2),:))
% theta = asin(343 * lag / fs / d / w_k)

%%%%%%%%%%% using cross-power spectrum %%%%%%%%%%% 
function timelag = cal_timelag(dst1, dst2, rcv_diff)

global c;
global fs;

 X1 = fft([dst1 ;zeros(length(dst1)-1,1)]);
 X2 = fft([dst2; zeros(length(dst2)-1,1)]);
%X1 = fft(dst1);
%X2 = fft(dst2);
f= ifft(X1.*conj(X2) / norm(X1) / norm(X2));
sft = ceil(length(f)/2);
f = [f(sft+1:end); f(1:sft)];
[maxx,lag] = max(f);
timelag = (lag-sft)/fs;
est_diff = timelag*c;
while abs(est_diff) > rcv_diff 
    [maxx,lag] = max(f(f<maxx));
    timelag = (lag-sft-1)/fs;
    est_diff = timelag*c;
end
% est_diff
% real_distDiff = norm(SetupStruc.src_traj - SetupStruc.mic_pos((1),:)) ...
%     - norm(SetupStruc.src_traj - SetupStruc.mic_pos((2),:))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dist = distance(a, b)
% implements the Euclidean distance formula to find
% the distance b/n the two points given.
if(length(a)~=length(b))
    error('Dimensions do not match!');
end
dist = sqrt(sum((a-b).^2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer = ellipseMerit(s)
% Defines a function to be minimized so as to localize a source.
% s -> sound source position. [x y z]
% m -> microphone positions. (known: in the reverse problem)
% [x1 y1 z1;
% x2 y2 z2;
% x3 y3 z3;
% x4 y4 z4]
% Delays -> d12, d13, d14, d23, d24, d34
% Find a vector of differences b/n reported delays and (geometrically)
% expected delays. Then, sum the squares of the vector.
% Because, we are aiming to minimize the sum of the squares in the over-
% determined case of more microphones than 3 (b/c we live in 3D).
global BUSHMicLoc;
global BUSHDelays;
vec = ellipseFun(s, BUSHMicLoc, BUSHDelays);
% In the future, divide each element by the PRECISION of the delay
% estimation. This could be the full width at half maximum of our
% cross correlation coeeficients graph.
answer = sum(vec.^2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function res = ellipseFun(s, m, delays)
% s -> sound source position. [x y z]
% m -> microphone positions. (known)
% [x1 y1 z1;
% x2 y2 z2;
% x3 y3 z3;
% x4 y4 z4]
% Delays -> d12, d13, d14, ... d23, d24,... d34...
nMic = size(m, 1);
% This is a clever way of calculating the # of Pairs of microphones.
nPairs = (nMic.^2 - nMic)./2;
% So, we will have as many equations as pairs of microphones.
res = zeros(nPairs,1);
% speed of sound
% Distance:- meters Time:- seconds
c = 343;
% Equations
% We expect the delay reported by cross correlation to equal
% the difference between the distances of the source to each microphone
% divided by the speed of sound.
% Distances b/n microphones and the source.
Dis = zeros(nPairs,1);
h = 1;
for k = 1:nMic
    for j = k+1:nMic
        diffD = distance(s, m(k,:)) - distance(s, m(j,:));
        Dis(h) = diffD;
        h = h+1;
        % if h>nPairs+1
            % error(); % needed only at debugging stage.
        % end
    end
end
% The final equation
for k=1:nPairs
    res(k)= Dis(k)./c - delays(k);
end
