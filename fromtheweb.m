function [answer, condition] = fromtheweb(simu, source, dataFile)
% Returns the estimated location of a single source from the delay
% information calculated using the cross correlation function AND
% the condition number of this estimation.
% Works on any number of microphones used to collect the data.
% The locations of the microphones should be hardcoded.
% simu -> simulation? :: 1=simulation 0=real data
% source -> location [x, y, z]. This is crucial during simulation.
% dataFile -> EXCEL file saved by the LabView data acquisition program
% UNITS: Distance:- meters Time:- seconds.
c = 343; % Speed of sound
% Microphone Positions. This is experiment specific!
% [x1 y1 z1;
% x2 y2 z2;
% x3 y3 z3; ...
% xn yn zn]
%%% MODIFY AS NEEDED
% MicLoc = [0.0, 0.0, 0.0; 1.0, 0.0, 0.0; 0.0, 1.0, 0.0; 1.0, 1.0, 1.0];
MicLoc = [
262, 0, 0;
85, -145, 0;
0, 0, 0;
0, -145, -74
];
% The following is an off value for the microphone locations. It helps
% us to estimate the condition number of the routine during simulations.
OffMicLoc =[
262.5, 0.5, 0.5;
85, -145, 0;
0, 0, 0;
0, -145, -74
];
% Make a good guess for the location of the source.
Guess = mean(MicLoc, 1);
%%% Comment out ONE OF THESE TWO as necessary.

% *1. Work on real data.
if (simu==0)
delays = generateDelays(dataFile, size(MicLoc,1))
% *2. Work on simulated data for testing purposes.
% Specify the location of the source to get
% the delays in this microphone configuration.
elseif (simu==1)
%%%PUT SOURCE HERE for SIMULATION
delays = simDelay(MicLoc, source);%%%MODIFY AS NEEDED
end
%%% Comment out ONE OF THESE TWO as necessary.
% If the system is NOT overdetermined, we have two ways of solving it.
% *1. Solve a system of non-linear equations using Newton's method.
% % % answer = newtonMethod('ellipseFun', Guess, MicLoc, delays);
% *2. The above approach may fail if there are more than 3 microphones,due
% to overdetermination. Here is a more general approach.
% Find the ArgMin of this function.
global BUSHMicLoc;
global BUSHDelays;
if (simu == 0)
BUSHMicLoc = MicLoc; % If this is not a simulation, use the values.
elseif (simu == 1)
% During simulation, use microphone values, which are slightly off.
BUSHMicLoc = OffMicLoc;
end
BUSHDelays = delays;
answer = fminsearch(@ellipseMerit, Guess);
%%% ASSESS the accuracy of the answer. (we should know where the source is)
forwardError = (norm(answer - source))./(norm(source));
% estimate the backward error, which describes how accurately we know
% the location of the microphone & the delay. (sometimes, the accuracy
% of the speed of sound can be a factor too.)
% During real experiments Microphone locations are known to within 2cm.
% During simulation the uncertainty introduced should be entered in here.
if (simu == 0)
backwardError = (2)./100;
elseif (simu == 1)
backwardError = (norm(MicLoc-OffMicLoc))./(norm(MicLoc));
end
% Evaluate the condition number of the problem.
condition = forwardError./backwardError;
%%display(condition);
%%% SUGGESTED TESTING (based on simulation):
% % % %Plot Merit vs z, constraining x&y to the exact souce coordinate.
% % % %EXPECT to see a minima, where z coincides with the source zcoordinate!
meritVal = [];
for zValue = ((-10*abs(source(3)))+source(3)):((10*abs(source(3)))+source(3))
    meritVal(end+1) = ellipseMerit([source(1), source(2), zValue]);
end
zValues = ((-10*abs(source(3)))+source(3)):((10*abs(source(3)))+source(3));
figure(2); plot(zValues, meritVal); title('TEST: Merit vs z');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer = generateDelays(dataFile, nMic)
% This automates the use of crossCorrN to find delays
% between pairs of signals.
% It returns an array of delays.
% dataFile -> EXCEL file by the LabView data acquisition program.
% nMic -> number of microphones used
data = load(dataFile);
delays = [];
for k = 1:nMic
    for j = k+1:nMic
        delays(end+1) = crossCorrN( data(:,k), data(:,j) );
    end
end
answer = delays;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer = simDelay(mPos, sPos)
% It computes the delay b/n signals recorded at different microphones.
% It takes locations of microphones and the source.
% sPos -> [x y z]
% mPos -> [x1 y1 z1;
% x2 y2 z2;
% ... ;
% xn yn zn]
% Works for any number of microphnes and a single source.
% Speed of sound
c = 343;
nMics = size(mPos, 1);
delays = [];
%micPairs = []; We probably don't need this SUGGESTED labeling.
% Get the delay b/n all pairs of microphones.
for k = 1:nMics
    disToK = distance(sPos, mPos(k,:));
    for j = k+1: nMics
        disToJ = distance(sPos, mPos(j,:));
        delays(end+1) = (disToK - disToJ)./c;
    end
end
% Return the delays
answer = delays;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer = crossCorrN(x, y, sampleRate, nSamples)
% It cross correlates the two signal parameters to find thier delay.
% It does a normalized cross correlation. This avoids ambiguities in
% picking a maximum.
% It makes advantage of reality (the fact that the delay can't possibly
% be bigger than *0.2* second in a room) to hasten the program.
% x & y -> signals to be cross-correlated.
% sampleRate -> sample rate of data acquisition.
% nSamples -> number of samples in the data acquisition.
%%%% SET these appropriately!!!
if nargin == 2 % Default Data Acquisition values
sampleRate = 15000;
nSamples = 65000;
end
minD = nSamples-floor((0.1.*sampleRate)); % 0.1. B/c max(Delay)=*0.2*
here
maxD = nSamples+floor((0.1.*sampleRate));
%%lengthR = maxD - minD +1;
lengthR = length(x) + length(y) - 1;
% % % minD = 1;
% % % maxD = lengthR;
R = zeros(1, lengthR);
% Do a normalized cross correlation.
meanX = mean(x);
meanY = mean(y);
denominatorX = sum((x - meanX).^2);
denominatorY = sum((y - meanY).^2);
denominator = sqrt(denominatorX.*denominatorY);
% The following is the common 'sliding business' of cross correlation.
for t=minD:maxD
    numerator = 0;
    for i =1:length(x)
        p = t - length(x);
        if ((i+p <=length(y)) && (i+p>=1) )
            numerator = numerator + ((x(i)-meanX).*( y(i+p) -meanY));
        elseif (i+p<1)
        % Zero padding
            numerator = numerator + (x(i)-meanX).*( 0 - meanY);
        else
            numerator = numerator + ((x(i)-meanX).*( 0 -meanY));
        end
    end
    R(t) = numerator./denominator;
end
% Find the delay
[maxim, argmaxim] = max(R);
answer = nSamples - argmaxim; % +ve -> D(x)>D(y) & -ve -> D(x)<D(y).
% Plot the cross correlation coefficients. (for verification by eye)
figure(1); plot(R,'.'); title('Cross-CorrelationN coeeficients');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer = distance(a, b)
% implements the Euclidean distance formula to find
% the distance b/n the two points given.
if(length(a)~=length(b))
    error('Dimensions do not match!');
end
answer = sqrt(sum((a-b).^2));

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function answer = loc1ConditionVis(z)
% Helps visualization of the condition number of fromtheweb routine
% as a function of source coordinates.
% Due to our limitations to 3D visualization, user picks
% a plane where the sources will be examined upon, by specifying
% a z value.
% z -> The above-mentioned z value.
figure(3);
cond = [];
xValues = [];
yValues = [];
for xVal = -2:2;
    for yVal = -2:2;
        [a, cond(end+1)] = fromtheweb(1, [xVal, yVal, z]);
        xValues(end+1)=xVal;
        yValues(end+1)=yVal;
    end
end
plot3(xValues, yValues, cond, '*');