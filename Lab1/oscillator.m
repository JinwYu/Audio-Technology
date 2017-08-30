function [miniMoogLjud] = oscillator(Fs, frequency, soundLength, waveType)

% Tidsvektorn (t) ska gå från 0	till ljudlängden, och
% delas	i 1/samplingsfrekvensen	antal steg.
t = (0:(1/Fs):soundLength);

% Skapa olika sorters vågformer.
if strcmp(waveType,'sawtooth')
    width = 0; % Noll och 1 låter likadant och ger mest övertoner enligt oss.
    miniMoogLjud = sawtooth(2*pi*frequency.*t, width);
end

if strcmp(waveType,'square')
    pulseW = 0.5; % SÃ¤tt pulsbredden till 50% fÃ¶r fyrkantsvÃ¥g
    % Skapa fyrkantsvÃ¥gen
    miniMoogLjud = square(2*pi*frequency.*t,pulseW);
end

if strcmp(waveType, 'triangle')
    dutyC = 0.5; % SÃ¤tt duty cycle till 50% fÃ¶r ren triangel
    % Skapa triangelvÃ¥gen
    miniMoogLjud = sawtooth(2*pi*frequency.*t,dutyC);
end

% Spelar upp ljudet.
%p = audioplayer(miniMoogLjud, Fs);
%playblocking(p);

% Plotta ljudet.
%figure();
%plot(miniMoogLjud);





