function [filteredSound] = applyFilter(sound, Fs, filterType)

% nte ordningen. D� Minimoogens VCF �r ett	24dB/oktav-filter,	
% dvs ett filter med fyra poler, ska filtret vara av fj�rde	ordningen.	
n = 4; 

% F�r data som samplats med 44100Hz som samplingsfrekvens, normalisera
% brytfrekvensen "Wn" genom att dividera den �nskade brytfrekvensen med 
% h�lften av samplingsfrekvensen, dvs. 22050.

Wn = 2200/(Fs/2); % Normaliserad brytningsfrekvens (cutoff frequency).

% Analogt l�gpassfilter. "b" och "a" �r filterkoefficienter.
[b,a] = butter(n,Wn, filterType); 

% Applicera filtret p� ljudet.
filteredSound = filter(b, a, sound);

% Plottar filtret.
freqz(b, a);

% Spektogram, f�r att se hur frekvensinneh�llet p�verkas av brytfrekvensen.
window = 512; % Antalet f�nster som ljudet delas in i.
noverlap = 256; % Antalet �verlapp mellan intilliggande f�nster.
nfft = 512; % Antalet samplingar som anv�nds f�r att ber�kna Fouriertransformen.

figure();
spectrogram(sound, window, noverlap, nfft, Fs, 'yaxis') % 'yaxis' s�tter vilken axel spektogrammet ska visas mot.

% Snygga till spektrogrammet.
ylim([0,2]);
title('Spektrogram av ljudet');
xlabel('Tid (s)');
ylabel('Frekvens (kHz)');