function MultiPlot( varargin )
%MULTIPLOT Mehrere Signale ploten
%  Eingabe: Signal, Abtastfrequenz, Name
%{
Bsp.:
MultiPlot(AMDemod, Fs, 'AM Demod',...
    DigitalesSignal, DACSampeFreq, 'resample');
%}

n = length(varargin);
figure('Name', 'Plots', 'NumberTitle', 'off');

for i = 1:3:n
    
    y = varargin(i);
    fs = varargin(i+1);
    Titel = varargin(i+2);
    
    x = 0:1/fs{1}:(length(y{1})-1)/fs{1};
    
    subplot(n/3, 1, ceil(i/3));
    plot(x, y{1});
    xlabel('Zeit (S)')
    title(Titel{1});
end

end