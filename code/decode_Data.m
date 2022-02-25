function [Graustufenbild , Infrarotbild, Latitude, Longitude, ...
    Falschfarbenbild,Positionsausgabe, RechenzeitAusgabe] = ...
    decode_Data(pathSatellitWav,pathSatellitMat)
%%DECODE_DATA 
% >>Methode zur Erstellung von den Satellitenbildern sowie Lokalisierung der
% Empfangsantenne. 
%
% Gruppe 3, Lyu Bingzhen, Philipp Hengel
%
% Methodenaufruf durch:
% [GB,IRB,Lat,Long,FFB,Pos,RZ] = decode_Data(pW,pM);
% Schnittstelle:
% i) pathSatellitWav: Pfad zu Wav-Datei 
%    pathSatellitMat: Pfad zu Mat-Datei 
% o) Graustufenbild: Matrix des Graustufenbildes 
%    Infrarotbild: Matrix des Infrarotbild 
%    Latitude: Breitengrad des Empfaengers
%    Longitude: Laengengrad des Empfaengers 
%    Falschfarbenbild: Matrix des Falschfarbenbildes
%    Positionsausgabe: Zeichenarray mit der Empfaenger Position
%    RechenzeitAusgabe: Zeichenarray mit den Rechenzeiten

    %% Dateien laden
    addpath(genpath('Doppler-Ortung'));
    addpath(genpath('Satellitenbilder'));
    
    load(pathSatellitMat); % WXSAT laden

    %% Doppler Lokalisierung
    timerVal = tic();
    
    [Latitude, Longitude, Positionsausgabe] = ...
        DopplerLokalisierung(pathSatellitWav, WXSAT);

    ZeitDoppler = toc(timerVal);

    %% Bild Dekodierung
    timerVal = tic();
    
    [Graustufenbild , Infrarotbild, Falschfarbenbild, DauerFM, DauerAM]=...
        Bilddekodierung(pathSatellitWav, WXSAT);
    
    ZeitBild = toc(timerVal);

    %% Ausgabe Rechenzeit
    RechenzeitAusgabe = sprintf(['\tAusgabe der Rechenzeit\nInsgesamt: '...
        '%.2f s\nDoppler Lokalisierung: %.2f s\nBild Dekodierung: %.2f '...
        's\nDavon FM Demodulation %.2f s und AM Demodulation %.2f s\n'],...
        ZeitDoppler+ZeitBild, ZeitDoppler, ZeitBild, DauerFM, DauerAM);

end

