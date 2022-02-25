function [ AMDemod ] = AMDemodulation(APTSignal, Fs)
%AMDEMODULATION AM Demodulation
% Schnittstelle:
% i) APTSignal: AM moduliertes Signal
%    Fs: Abtastfrequenz
% o) AMDemod: AM demoduliertes Signal

% Parameter der AM-Modulation:
AMFreq = 2400; AMBandbreite = 4160; %Modulationsgrad = 0.87;


%% Auswahl verschiedener Methoden
modulator = 1;

%% Geradeausempfaenger, Huellkurvenempfaenger
% s. 361 Signaluebertragung, Ohm, Lueke, Springer
if modulator == 1

    % Bandpass Filter
    Grenzfrequenz = [(AMFreq-(AMBandbreite/2)), (AMFreq+(AMBandbreite/2))];
    FreqNormalisiert = Grenzfrequenz./(Fs/2);
    [b, a] = butter(5, FreqNormalisiert, 'bandpass');
    AMDemod = filter(b, a, APTSignal);

    % Betrag, Gleichrichtung
    AMDemod = abs(AMDemod);

    % Tiefpass Filter
    Grenzfrequenz = AMBandbreite/2;
    FreqNormalisiert = Grenzfrequenz/(Fs/2);
    [b, a] = butter(5, FreqNormalisiert, 'low');
    AMDemod = filter(b, a, AMDemod);

end

%% Synchronous Detector, Squaring Detector
% https://en.wikibooks.org/wiki/Communication_Systems/Amplitude_Modulation
if modulator == 2

    % Bandpass Filter
    Grenzfrequenz = [(AMFreq-(AMBandbreite/2)), (AMFreq+(AMBandbreite/2))];
    FreqNormalisiert = Grenzfrequenz./(Fs/2);
    [b, a] = butter(5, FreqNormalisiert, 'bandpass');
    AMDemod = filter(b, a, APTSignal);
  
    AMDemod = AMDemod.^2;
    
    % Tiefpass Filter
    Grenzfrequenz = AMBandbreite/2;
    FreqNormalisiert = Grenzfrequenz/(Fs/2);
    [b, a] = butter(5, FreqNormalisiert, 'low');
    AMDemod = filter(b, a, AMDemod);
    
    AMDemod = sqrt(abs(AMDemod)); 
    % Der Betrag stellt sicher, dass keine komplexen Werte vorliegen.

end
end