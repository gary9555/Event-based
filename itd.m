function angle = itd(data)

c = 343;          % sound speed
mic_dist = 0.1;   % distance between the two mics
fs = 44100;

dst1 = data(:,(1));
dst2 = data(:,(2));

% X1 = fft([dst1; zeros(length(dst1)-1,1)]);
% X2 = fft([dst2; zeros(length(dst2)-1,1)]);
X1 = fft(dst1);
X2 = fft(dst2);
f= ifft(X1.*conj(X2) / norm(X1) / norm(X2));
sft = ceil(length(f)/2);
f = [f(sft+1:end); f(1:sft)];
[maxx,lag] = max(f);
timelag = (lag-sft)/fs;
est_diff = timelag*c;
while abs(est_diff) > mic_dist 
    [maxx,lag] = max(f(f<maxx));
    timelag = (lag-sft-1)/fs;
    est_diff = timelag*c;
end

if est_diff ~= 0
    %angle = (pi/2 - atan((0.01/est_diff^2-1) / (0.01/est_diff^2-1+est_diff^2/4-0.05^2)^0.5))/pi*180;
    angle = (pi/2 - atan(sqrt( 0.01/est_diff^2 - 1))) / pi * 180;
    if est_diff < 0
        angle = -angle;
    end
else
    angle = 0;
end

end