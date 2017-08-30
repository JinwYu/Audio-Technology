% Init.
Fs = 44100; % Samplingsfrekvensen.
frequency = 55; % Frekvens i HZ.
soundLength = 3; % Tid i sekunder.

% Skapar oscillatorerna med sawtooths. B�ST FYLLIGAST LJUD
os1 = oscillator(Fs, frequency, soundLength,'sawtooth');
os2 = oscillator(Fs, frequency-1, soundLength,'sawtooth');
os3 = oscillator(Fs, frequency+1, soundLength,'sawtooth');

% Skapar oscillatorerna med square. SVAGT LJUD
%os1 = oscillator(Fs, frequency, soundLength,'square');
%os2 = oscillator(Fs, frequency-1, soundLength,'square');
%os3 = oscillator(Fs, frequency+1, soundLength,'square');

% Skapar oscillatorerna med triangle. BASLJUD
%os1 = oscillator(Fs, frequency, soundLength,'triangle');
%os2 = oscillator(Fs, frequency-1, soundLength,'triangle');
%os3 = oscillator(Fs, frequency+1, soundLength,'triangle');

% Varierande v�gformer.
%os1 = oscillator(Fs, frequency, soundLength,'sawtooth');
%os2 = oscillator(Fs, frequency-1, soundLength, 'sawtooth');
%os3 = oscillator(Fs, frequency+1, soundLength, 'triangle');

% Summerar ljudet, fixar skalningen genom att dela p� antal oscillatorer.
summedSound = (os1 + os2 + os3)/3;

% Applicerar filtret d�r de tillg�ngliga filtertyperna �r: low, bandpass,
% high & stop. "bandpass" och "stop" funkar inte, f�r n�got error.
filteredSound = applyFilter(summedSound, Fs, 'high');

% Skapa en audioplayer f�r det summerade ljudet innan filtrering.
%p = audioplayer(summedSound, Fs);  

% Skapa en audioplayer f�r det filtrerade ljudet.
p = audioplayer(filteredSound, Fs);

% Spela ljudet.
playblocking(p);