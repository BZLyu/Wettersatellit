function [ res ] = Spektrogramm( filenamewav )
%SPEKTROGRAMM Erstellt ein Spektrogramm
% Schnittstelle:
% i) filenamewav:  Pfad zu Wav-Datei 
% o) res:  Matrix des Spektrogrammes 

    info = audioinfo(filenamewav);
    Fs = info.SampleRate;

    AuswahlGr = Fs;
    AuswahlN = floor(info.TotalSamples/AuswahlGr) - 1;

    N = 10000;
    res = zeros(N, AuswahlN);

    for i=1:AuswahlN

        % Jeweils eine Sekunde des Signales laden.
        [IQSignal, ~] = audioread(filenamewav,...
            [(i-1)*AuswahlGr + 1,...
            i*AuswahlGr]); 
        
        % Amplitudenfehler
        alpha = sqrt(sum(IQSignal(:,2).^2)/sum(IQSignal(:,1).^2));
        
        % Spektrogramm mittels fft berechnen
        temp = abs(fftshift(fft(IQSignal(:,1) +1i.*IQSignal(:,2)./alpha)));
 
        % Nur ein Ausschnitt des Spektrogrammes wird verwendet
        res(:,i) = temp(floor(length(temp)/2-N/2+1):floor(length(temp)/2+N/2));
        
        % Ergebnis normieren
        res(:,i) = (res(:,i)-min(res(:,i)))./(max(res(:,i))-min(res(:,i)));
    end

    
end