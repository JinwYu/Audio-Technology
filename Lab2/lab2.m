Fs = 44100; % Samplingsfrekvensen.

% Skapa en sinuston.
freq = 195; % Hz
soundLength = 3; 
t = (0:(1/Fs):(soundLength)); % Tidsvektor.
sineSound = sin(2*pi*freq.*t);

% Skapa white noise.
m = 1;
n = 132301;
p = 0.3;
%whiteSound = wgn(m, n, p);

% Förbättringar. Skapa	därför	en frekvensmodulerad	signal	som	byggs	
% upp	av	en	sinusoscillator	i	F0,	som	frekvensmoduleras	
% av	en	sinusoscillator	i	F1,	som	moduleras	av	en	sinus	i	F2,
% som	moduleras	av	en	sinus	i	F3.	
% Liknande	detta,	fast	med	fyra	operatorer:

fmDepth1 = 3000; % Ju högre värde, ger mer övertoner.
fmDepth2 = 500; 
fmDepth3 = 200; 

% Den här ersätter formanterna vi fått från bruset.
whiteSound = sin(2*pi*t.*freq+ fmDepth1*sin(2*pi*t.*freq+ fmDepth2*sin(2*pi*t.*freq+ fmDepth3*sin(2*pi*t.*freq))));
whiteSound = whiteSound;


% frekvensVektor = [startFrekvens:skillnad mellan startFrekvens och
% slutFrekvens/(length(t)-1):slutFrekvens];
frekvensVektor = [140:((220-140)/(length(t)-1)):220];

%Detta	läggs	sedan	till	F0	genom:
fundamentalSinus = sin(2*pi*freq.*frekvensVektor.*t);

% Bredbandigt ljud.
%combinedSound_F0 = sineSound*0.5 + whiteSound*0.9;
combinedSound_F0 = whiteSound*0.9;

% Kolla så combinedSound inte överstiger 1.
%plot(combinedSound_F0);

% Formant frequencies. Valde ljudet "oo" för en kvinna.
f1 = 370;
f2 = 950;
f3 = 2670;

% För att forma formanterna behövs tre bandpassfilter som skapar 
% övertonsserien som gör talljudet. 
% Analogt filter. "b" och "a" är filterkoefficienter som ges i output.
n = 2; 

% Normaliserade brytningsfrekvenser (cutoff frequencies).
cutoffFreq_f1 = [(f1-f1*0.1)/(Fs/2), (f1+f1*0.1)/(Fs/2)];
cutoffFreq_f2 = [(f2-f2*0.07)/(Fs/2), (f2+f2*0.07)/(Fs/2)];
cutoffFreq_f3 = [(f3-f3*0.05)/(Fs/2), (f3+f3*0.05)/(Fs/2)];

[b,a] = butter(n, cutoffFreq_f1, 'bandpass'); 
[d,c] = butter(n, cutoffFreq_f2, 'bandpass'); 
[f,e] = butter(n, cutoffFreq_f3, 'bandpass'); 

% Applicera filtret på ljudet.
filteredSound_F1 = filter(b, a, combinedSound_F0);
filteredSound_F2 = filter(d, c, combinedSound_F0);
filteredSound_F3 = filter(f, e, combinedSound_F0);

% Plottar filtret.
%freqz(b, a);
%freqz(d, c);
%freqz(f, e);

% Konvertera formantljuden dB till magnitud. Värden togs från 
% labkompendiet för "aw"-ljudet.
filteredSound_F1 = db2mag(-3)*filteredSound_F1;
filteredSound_F2 = db2mag(-19)*filteredSound_F2;
filteredSound_F3 = db2mag(-43)*filteredSound_F3;

% Summera alla fyra ljud.
summedSound = 0.2*fundamentalSinus + filteredSound_F1 + filteredSound_F2 + filteredSound_F3;

% Kontrollera summedSound's ljudnivå.
summedSound = summedSound;
%plot(summedSound)

% Infade och utfade.
fadeVektor = [0:(1/4410):1];

% 
oneVektor = ones(1, 123479);

fadingVektor = [fadeVektor oneVektor fliplr(fadeVektor)];

y = fadingVektor.*summedSound;
y = y*1.6;

plot(y);

% Skapa en audioplayer för det filtrerade ljudet.
p = audioplayer(y, Fs);

% Spela ljudet.
playblocking(p);





