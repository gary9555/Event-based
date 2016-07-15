
clear
[src,fs] = audioread('human.wav');

c = 343; % sound speed

roomDim = [5 5 3];
rcv_loc1 = [2.45  .1 .1];
rcv_loc2 = [2.55 .1 .1];
rcv_loc  = [rcv_loc1;rcv_loc2];
src_loc = [4.9 4.9 .1];

src = src(:,(1));

[SetupStruc] = ISM_setup(roomDim, src_loc, rcv_loc, fs);
RIR = fast_ISM_RIR_bank(SetupStruc,'fastISM_RIRs.mat');
dst = ISM_AudioData('fastISM_RIRs.mat',src);

dst1 = dst(:,(1));
dst2 = dst(:,(2));

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
while abs(est_diff) > 0.1 
    [maxx,lag] = max(f(f<maxx));
    timelag = (lag-sft-1)/fs;
    est_diff = timelag*c;
end

real_diff = norm(src_loc - rcv_loc1) - norm(src_loc - rcv_loc2)
%real_angle = asin((src_loc(1)-1)/norm(src_loc-mean(rcv_loc,1)));
est_diff

real_angle = atan((src_loc(1) - 2.5) / (src_loc(2)-rcv_loc1(2)))  

est_angle = pi/2 - atan((0.01/est_diff^2-1) / (0.01/est_diff^2-1+est_diff^2/4-0.05^2)^0.5)
