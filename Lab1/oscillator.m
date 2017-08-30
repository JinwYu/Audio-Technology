function [miniMoogLjud] = oscillator(Fs, frequency, soundLength, waveType)

% Tidsvektorn (t) ska g� fr�n 0	till ljudl�ngden, och
% delas	i 1/samplingsfrekvensen	antal steg.
t = (0:(1/Fs):soundLength);

% Skapa olika sorters v�gformer.
if strcmp(waveType,'sawtooth')
    width = 0; % Noll och 1 l�ter likadant och ger mest �vertoner enligt oss.
    miniMoogLjud = sawtooth(2*pi*frequency.*t, width);
end

if strcmp(waveType,'square')
    pulseW = 0.5; % Sätt pulsbredden till 50% för fyrkantsvåg
    % Skapa fyrkantsvågen
    miniMoogLjud = square(2*pi*frequency.*t,pulseW);
end

if strcmp(waveType, 'triangle')
    dutyC = 0.5; % Sätt duty cycle till 50% för ren triangel
    % Skapa triangelvågen
    miniMoogLjud = sawtooth(2*pi*frequency.*t,dutyC);
end

% Spelar upp ljudet.
%p = audioplayer(miniMoogLjud, Fs);
%playblocking(p);

% Plotta ljudet.
%figure();
%plot(miniMoogLjud);





