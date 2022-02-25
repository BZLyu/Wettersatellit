function  MultiSpektrum( varargin )
%MULTISPEKTRUM Mehrere Spektren anzeigen
% Eingabe: Signal, Abtastfrequenz, Name
%{
Bsp.:
MultiSpektrum(y(:,1), Fs, 'fm1',...
    y(:,2), Fs, 'fm',...
    y(:,3), Fs, 'fm');
%}

n = length(varargin);
figure('Name', 'Spektren', 'NumberTitle', 'off');

for i = 1:3:n
    
    x = varargin(i);
    Fs = varargin(i+1);
    Titel = varargin(i+2);
    
    y = fftshift(fft(x{1}));
    yx = linspace(-Fs{1}/2, Fs{1}/2, length(y));
    
    subplot(n/3, 1, ceil(i/3));
    plot(yx, abs(y));
    xlabel('Frequenzen (Hz)')
    ylabel('Betrag')
    title(Titel{1});
end

end