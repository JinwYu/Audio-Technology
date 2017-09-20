close all;
clear all;

% Read the sound.
[fullDialogue, Fs] = audioread('forensisktljud.wav');

dialogue1 = fullDialogue(3*Fs:7*Fs); % From 3-7s.
dialogue2 = fullDialogue(15*Fs:20*Fs); % From 15-20s.
fullDialogueMono = fullDialogue(1*Fs:59*Fs); % Full dialogue.

y = fullDialogueMono;
%% Plot the sound to find irregularities in the waveform.
figure
plot(fullDialogue);

%% Plot with FFT.
m = length(y);
n = pow2(nextpow2(m));
dialogue1FFT = fft(y,n);

% Beräknar power:n. Använder "conj" för att returnera konjugatet	av divisionen.	
power = dialogue1FFT.*conj(dialogue1FFT)/n;

f = (0:n-1)*(Fs/n);
figure
loglog(f,power);    % Plot.

% Snygga till plotten.
xlim([1,20000]);
ylabel('Power');
xlabel('Frekvens (Hz)');
title('Effektspektrum av ljudet');

% Plot:en ger att höga frekvenser har låg power. Frekvenser mellan ca.
% 100Hz och 1000Hz har högst power i ljudet.

%% Filtrera	för	hörbarhet och äkthetsundersökning.
% Filtrera bort frekvenser under 200Hz för enbart brus.
cutoffFreq = 140/(Fs/2); % I Hz.
filterOrder = 6;
[b,a] = butter(filterOrder, cutoffFreq, 'high'); 
y = filter(b, a, y);

% Lowpass-filter för att ta bort onödiga övre frekvenser.
cutoffFreq = 4000/(Fs/2); % I Hz.
filterOrder = 20;
[b,a] = butter(filterOrder, cutoffFreq, 'low'); 
y = filter(b, a, y);

% % Gör notchfiltrering.
% filterOrderNotch = 2;
% [b, a] = butter(filterOrderNotch, [50 75]./(Fs/2), 'stop');
% filteredDialogue2 = filter(b, a, filteredDialogue1);

%% Brusreducering av ljudet med Savitzky-Golay-filtret.
% order sätter	polynomialordningen	(som	måste	vara	mindre	än	
% fönsterbredden)	och	framelen är	fönsterbredden	(som	måste	
% vara	ett	udda	tal).
order = 3;
framelen = 45;
y = sgolayfilt(y,order,framelen);

%% Förstärka och komprimera	förloppet.
amplitudeFactor = 2.5;
y = y.*amplitudeFactor;
y = y/max(abs(y));
% plot(dialogue1);

% Lägger till distortion.
distLevel = 5;
y = (distLevel*y)./(1+distLevel*abs(y));

%% Gör mono av ljudet.
leftChannel = y(:,1);
rightChannel = y(1,:);

% Två olika sätt:
% 1. Summera kanalerna till en vektor och släcker ut en del information.
monoDialogue = leftChannel + rightChannel;

% 2. Fasvänder en av kanalerna, då släcks visst ljud ut när du summerar
% kanalerna.
leftChannel=leftChannel.*-1; % Fasvändning.
phaseInvertedMonoDialogue = leftChannel + rightChannel;

y = monoDialogue;

%% Kontroll	av	DC-offset.
% Vid	ljudinspelning	är	DC-offset	en	oönskad	egenskap	i	det	
% inspelade	ljudet.	Fenomenet orsakas	av	dålig,	trasig	och	
% lågkvalitativ	utrustning.	DC-offseten	är	en	förskjutning	av	
% DCnivån i	en	signal,	där	signalen	inte	längre	svänger	runt	0	
% utan	ovanför	eller	nedanför	0-nivån

%% Kontroll av jordbrum.
% Bandpass-filtrera runt 50Hz för att hitta jordbrum.
cutoffFreq = [40/(Fs/2), 60/(Fs/2)]; % I Hz.
filterOrder = 2;
[b,a] = butter(filterOrder, cutoffFreq, 'bandpass'); 
brumKontroll = filter(b, a, fullDialogueMono);

%% Spela upp ljudet.
p = audioplayer(y,Fs);
playblocking(p)
plot(y);

%% Plot a spectrogram.
window = 512; % Antalet fönster som ljudet delas in i.
noverlap = 256; % Antalet överlapp mellan intilliggande fönster.
nfft = 512; % Antalet samplingar som används för att beräkna Fouriertransformen.
figure
spectrogram(transpose(brumKontroll), window, noverlap, nfft, Fs, 'yaxis')

Snygga till spektrogrammet.
colorbar
ylim([0,20]); % Frekvensintervallet som ska visas i kHz.
%ylim([0.03,0.08]); % För att studera brum.
title('Spektrogram av ljudet');
