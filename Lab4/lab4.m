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

% Ber�knar power:n. Anv�nder "conj" f�r att returnera konjugatet	av divisionen.	
power = dialogue1FFT.*conj(dialogue1FFT)/n;

f = (0:n-1)*(Fs/n);
figure
loglog(f,power);    % Plot.

% Snygga till plotten.
xlim([1,20000]);
ylabel('Power');
xlabel('Frekvens (Hz)');
title('Effektspektrum av ljudet');

% Plot:en ger att h�ga frekvenser har l�g power. Frekvenser mellan ca.
% 100Hz och 1000Hz har h�gst power i ljudet.

%% Filtrera	f�r	h�rbarhet och �kthetsunders�kning.
% Filtrera bort frekvenser under 200Hz f�r enbart brus.
cutoffFreq = 140/(Fs/2); % I Hz.
filterOrder = 6;
[b,a] = butter(filterOrder, cutoffFreq, 'high'); 
y = filter(b, a, y);

% Lowpass-filter f�r att ta bort on�diga �vre frekvenser.
cutoffFreq = 4000/(Fs/2); % I Hz.
filterOrder = 20;
[b,a] = butter(filterOrder, cutoffFreq, 'low'); 
y = filter(b, a, y);

% % G�r notchfiltrering.
% filterOrderNotch = 2;
% [b, a] = butter(filterOrderNotch, [50 75]./(Fs/2), 'stop');
% filteredDialogue2 = filter(b, a, filteredDialogue1);

%% Brusreducering av ljudet med Savitzky-Golay-filtret.
% order s�tter	polynomialordningen	(som	m�ste	vara	mindre	�n	
% f�nsterbredden)	och	framelen �r	f�nsterbredden	(som	m�ste	
% vara	ett	udda	tal).
order = 3;
framelen = 45;
y = sgolayfilt(y,order,framelen);

%% F�rst�rka och komprimera	f�rloppet.
amplitudeFactor = 2.5;
y = y.*amplitudeFactor;
y = y/max(abs(y));
% plot(dialogue1);

% L�gger till distortion.
distLevel = 5;
y = (distLevel*y)./(1+distLevel*abs(y));

%% G�r mono av ljudet.
leftChannel = y(:,1);
rightChannel = y(1,:);

% Tv� olika s�tt:
% 1. Summera kanalerna till en vektor och sl�cker ut en del information.
monoDialogue = leftChannel + rightChannel;

% 2. Fasv�nder en av kanalerna, d� sl�cks visst ljud ut n�r du summerar
% kanalerna.
leftChannel=leftChannel.*-1; % Fasv�ndning.
phaseInvertedMonoDialogue = leftChannel + rightChannel;

y = monoDialogue;

%% Kontroll	av	DC-offset.
% Vid	ljudinspelning	�r	DC-offset	en	o�nskad	egenskap	i	det	
% inspelade	ljudet.	Fenomenet orsakas	av	d�lig,	trasig	och	
% l�gkvalitativ	utrustning.	DC-offseten	�r	en	f�rskjutning	av	
% DCniv�n i	en	signal,	d�r	signalen	inte	l�ngre	sv�nger	runt	0	
% utan	ovanf�r	eller	nedanf�r	0-niv�n

%% Kontroll av jordbrum.
% Bandpass-filtrera runt 50Hz f�r att hitta jordbrum.
cutoffFreq = [40/(Fs/2), 60/(Fs/2)]; % I Hz.
filterOrder = 2;
[b,a] = butter(filterOrder, cutoffFreq, 'bandpass'); 
brumKontroll = filter(b, a, fullDialogueMono);

%% Spela upp ljudet.
p = audioplayer(y,Fs);
playblocking(p)
plot(y);

%% Plot a spectrogram.
window = 512; % Antalet f�nster som ljudet delas in i.
noverlap = 256; % Antalet �verlapp mellan intilliggande f�nster.
nfft = 512; % Antalet samplingar som anv�nds f�r att ber�kna Fouriertransformen.
figure
spectrogram(transpose(brumKontroll), window, noverlap, nfft, Fs, 'yaxis')

% Snygga till spektrogrammet.
colorbar
ylim([0,20]); % Frekvensintervallet som ska visas i kHz.
%ylim([0.03,0.08]); % F�r att studera brum.
title('Spektrogram av ljudet');
