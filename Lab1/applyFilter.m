function [filteredSound] = applyFilter(sound, Fs, filterType)

% nte ordningen. Då Minimoogens VCF är ett	24dB/oktav-filter,	
% dvs ett filter med fyra poler, ska filtret vara av fjärde	ordningen.	
n = 4; 

% För data som samplats med 44100Hz som samplingsfrekvens, normalisera
% brytfrekvensen "Wn" genom att dividera den önskade brytfrekvensen med 
% hälften av samplingsfrekvensen, dvs. 22050.

Wn = 2200/(Fs/2); % Normaliserad brytningsfrekvens (cutoff frequency).

% Analogt lågpassfilter. "b" och "a" är filterkoefficienter.
[b,a] = butter(n,Wn, filterType); 

% Applicera filtret på ljudet.
filteredSound = filter(b, a, sound);

% Plottar filtret.
freqz(b, a);

% Spektogram, för att se hur frekvensinnehållet påverkas av brytfrekvensen.
window = 512; % Antalet fönster som ljudet delas in i.
noverlap = 256; % Antalet överlapp mellan intilliggande fönster.
nfft = 512; % Antalet samplingar som används för att beräkna Fouriertransformen.

figure();
spectrogram(sound, window, noverlap, nfft, Fs, 'yaxis') % 'yaxis' sätter vilken axel spektogrammet ska visas mot.

% Snygga till spektrogrammet.
ylim([0,2]);
title('Spektrogram av ljudet');
xlabel('Tid (s)');
ylabel('Frekvens (kHz)');