close all;
clear all;

% Read the dry sound.
[drySound, Fs] = audioread('AnalogRytm_120BPM.wav');

% Read the target sound.
[targetSound, Fs] = audioread('TimeFactor_RE501_120BPM.wav');
%% 


% The vector for the delayed sound.
delayedSound = drySound;

delayTime = 16550; % The delay time in samples.

% Create the delay.
n = 4; % Nr of poles.
cutoffFreq = 4500;
for i = 1:4    
    % Add zeros before the sound.
    delayArray = padarray(drySound, i*delayTime, 'pre'); 
    
    % Cut the matrix length to match the dry sound's length and
    % lower the amplitude per each iteration.
    delayArrayCut = (1/(i*1.3)) * delayArray(1:length(drySound), :);
    
    % High cut/Low pass filter the following delays.
    Wn = (cutoffFreq-(i*700)) / (Fs/2);

    % Create the high cut/low pass filter
    [b,a] = butter(n, Wn, 'low'); 

    % Applicera filtret på ljudet.
    filteredDelay = filter(b, a, delayArrayCut);
    
    % Sum with the dry sound.
    delayedSound = delayedSound + filteredDelay;
end
%% 

% Create the overdrive (distortion) effect, by the louder the sound is
% the more the soundwave becomes a square wave and therefore creates
% distortion.
distF = 0.5; 
distSound = (delayedSound*distF) ./ (1+distF*abs(delayedSound));

% Double the amplitude.
distSound = distSound * 2;

% Normalize the sound.
delayedSound = distSound./max(distSound);

% Bandpass filter.
n = 2; 
lowCutOffFreq = 30;
highCutOffFreq = 10000;
cutoffFreq = [ lowCutOffFreq/(Fs/2), highCutOffFreq/(Fs/2)];

[b,a] = butter(n, cutoffFreq, 'bandpass'); 

BPfilteredSound = filter(b, a, delayedSound);
%% 

% Create the reverb effect.
soundVector = BPfilteredSound; 
decay = 60; % In ms.

% Simulating Schroeders reverberator.
for i = 0:2
    reverbLength = ceil((decay/1000)*Fs / (3^i)); 

    soundVector = [soundVector;zeros(abs(decay/100)*Fs,2)];
    
    b = zeros(1, reverbLength+1);
    b(1) = -0.7;
    b(reverbLength+1) = 1;

    a = zeros(1, reverbLength+1);
    a(1) = 1;
    a(reverbLength+1) = -0.7;

    reverbedSound = filter(b, a, soundVector);
    soundVector = reverbedSound; 
end
%% 

% Adding distortion on the reverb because the target loop's reverb sounds
% it has some overdrive on it.
distF = 1; 
soundVector = (soundVector*distF) ./ (1+distF*abs(soundVector));

% Put the reverb sounds through a low pass filter.
% 8000Hz and n = 2;
[b,a] = butter(1,1000/(Fs/2),'low');
summedReverbSound = filter(b, a, soundVector);
summedReverbSound = summedReverbSound(1:length(drySound), :);


%% 

% Create background noise.
freq = 50;
soundLength = 8; 
t = (0:(1/Fs):(soundLength)); % Tidsvektor.
sineSound = 0.03*sin(2*pi*freq.*t);
sineSound = sineSound(1:length(drySound));
sineSound = transpose(sineSound);
%% 

% Create white noise.
m = length(drySound);
n = 1;
p = 0.06;
whiteSound = wgn(m, n, p);
whiteSound = whiteSound/(10*max(abs(whiteSound)));
%% 

% Filter with a high cut/low pass filter.
n = 4; 
Wn = 4000/(Fs/2);
[b,a] = butter(n,Wn, 'low'); 
noise = filter(b, a, whiteSound);
%% 

% Create the final result.
finalSound = 1*drySound + 0.3*summedReverbSound + 0.4*sineSound + 0.06*noise;
p = audioplayer(finalSound, Fs);
playblocking(p);  

figure
plot(finalSound);
figure
plot(targetSound);