function [BildA , BildB, BildRGB, DauerFM, DauerAM] = ...
    Bilddekodierung(pathSatellitWav, WXSAT)
%%BILDDEKODIERUNG Erstellt Graustufen-, Infrarot- und Falschfarbenbild
% Schnittstelle:
% i) pathSatellitWav:  Pfad zu Wav-Datei 
%    WXSAT: geladene WXSAT Daten
% o) BildA: Matrix des Graustufenbildes
%    BildA: Matrix des Infrarotbildes
%    BildRGB: Matrix des Falschfarbenbildes
%    DauerFM: Dauer der FM-Demodulation
%    DauerAM: Dauer der AM-Demodulation

    %% Start
    fprintf('Satellit: %s\nFlugrichtung: %s\nAufnahme Datum: %s\n\n',...
        WXSAT.satellite, WXSAT.flightdir,...
        datetime(WXSAT.recordstart,'ConvertFrom','juliandate'));

    info = audioinfo(pathSatellitWav);
    Fs = info.SampleRate;
    FsDAC = 4160;

    %% Signal stueckweise nacheinander laden und demodulieren
    APTSignal = zeros(ceil(info.TotalSamples/(Fs/FsDAC)), 1);

    % Aufteilung des Signales
    AuswahlFaktor = 25;
    AuswahlGr = AuswahlFaktor*Fs;
    if (AuswahlGr > info.TotalSamples)
        AuswahlGr = info.TotalSamples;
    end
    AuswahlN = floor(info.TotalSamples/AuswahlGr);
    AuswahlRest = rem(info.TotalSamples, AuswahlGr);

    assert(AuswahlN*AuswahlGr + AuswahlRest == info.TotalSamples);

    DauerFM = 0;
    DauerAM = 0;

    % Stueckweise laden
    for i=1:AuswahlN

        if i==1
            [IQSignal, ~] = audioread(pathSatellitWav,...
                [(i-1)*AuswahlGr + 1,...
                i*AuswahlGr + 1]);
        else % Wird benoetigt, wenn AuswahlRest = 0 ist.
            [IQSignal, ~] = audioread(pathSatellitWav,...
                [(i-1)*AuswahlGr,...
                i*AuswahlGr]);
        end
        

        % Amplitudenfehler Korrektur und FM Demodulation
        tic;
        APTSignalTemp = FMDemodulation(IQSignal(:,1), IQSignal(:,2)); 
        DauerFM = DauerFM + toc;
        
             
        % AM Demodulation
        tic;
        APTSignalTemp = AMDemodulation(APTSignalTemp, Fs);
        DauerAM = DauerAM + toc;
        

        % Abtastfrequenz anpassen
        APTSignalTemp = resample(APTSignalTemp, FsDAC, Fs);
        
      
        % Ergebnis in APTSignal speichern
        APTSignal((i-1)*AuswahlFaktor*FsDAC+1:i*AuswahlFaktor*FsDAC)...
            = APTSignalTemp;

    end

    % Letztes Stueck laden
    if (AuswahlRest ~= 0)

         [IQSignal, ~] = audioread(pathSatellitWav,...
            [AuswahlN*AuswahlGr + 1,...
            AuswahlN*AuswahlGr + AuswahlRest]);

        tic;
        APTSignalTemp = FMDemodulation(IQSignal(:,1), IQSignal(:,2));
        DauerFM = DauerFM + toc;

        tic;
        APTSignalTemp = AMDemodulation(APTSignalTemp, Fs);
        DauerAM = DauerAM + toc;

        APTSignalTemp = resample(APTSignalTemp, FsDAC, Fs);

        APTSignal(end-length(APTSignalTemp)+1:end)...
            = APTSignalTemp;

    end
    clear APTSignalTemp IQSignal;

    %fprintf('FM Demodulation: %f Sekunden\nAM Demodulation: %f Sekunden\n',...
    %   DauerFM, DauerAM);
    %% Signale Ploten
    %{
    MultiPlot(y(:,3), Fs, 'FM Demod Richtig',...
        FMDemod, Fs, 'FM Demod',...
        APTDaten, DACSampleFreq, 'AM Demoduliert');

    MultiSpektrum(FMDemod, Fs, 'FM demod',...
        y(:,3), Fs, 'FM demod Richtig',...
        y(:,1)+ i*y(:,2), Fs, 'I Q Singal');
    %}

    %% Zeilensynchronisation & Bildaufbau
    APTSignal = APTSignal - mean(APTSignal); % Mittelwertfrei, vor Funktionsaufruf

    [BildA, BildB, BildLenX, BildLenY]...
        = BilderErstellen(APTSignal, FsDAC);
    clear APTSignal;

    % Bei einem Ueberflug von Sued nach Nord wird das Bild um 180° gedreht.
    if strcmp(WXSAT.flightdir, 'SN')
        BildA = imrotate(BildA, 180);
        BildB = imrotate(BildB, 180);
    end

    %% Graustufenbilder anzeigen
    %figure('Name', 'Graustufenbilder', 'NumberTitle', 'off');
    %imshowpair(BildA, BildB, 'montage', 'Scaling', 'none');

    %% Falschfarbendarstellung HSV
    BildHSV = zeros(BildLenX, BildLenY, 3);
    BildHSV(:,:,1) = BildB;     % Farbwert
    BildHSV(:,:,2) = 0.7;       % Saettigung
    BildHSV(:,:,3) = BildA;     % Hellwert

    % Farben aendern, indem die Farbwerte zwischen 0 und 1 verschoben werden.
    BildHSV(:,:,1) = mod(BildHSV(:,:,1) + 0.8, 1);

    BildRGB = hsv2rgb(BildHSV);

    return; % Alternativen Code nicht ausfuehren.

    %% Falschfarbendarstellung Colormap
    %[BildA, BildB] = deal(BildB, BildA); % Reihenfolge tauschen

    BlendMode = 'Soft Light'; % https://en.wikipedia.org/wiki/Blend_modes
    switch BlendMode
        case 'Alpha Blending'
            Alpha = 0.7; 
            BildAB = im2uint8(Alpha.*BildA + (1-Alpha).*BildB);
        case 'Multiply'
            BildAB = im2uint8(BildA.*BildB);
        case 'Screen blending'
            BildAB = im2uint8(1-(1-BildA).*(1-BildB));
        case 'Overlay'
            BildAB = im2uint8((BildA<0.5).*(2.*BildA.*BildB) ...
                            + (BildA>= 0.5).*(1-(1-BildA).*(1-BildB)));
        case 'Hard Light'
            BildAB = im2uint8((BildA<0.5).* (1-(1-BildA).*(1-BildB))...
                            + (BildA>= 0.5).*(2.*BildA.*BildB));
        case 'Soft Light'
            BildAB = im2uint8(BildA.^(2.^(2*(0.5-BildB))));
        otherwise
            error('Blend Mode nicht gefunden.');
    end
    figure('Name', BlendMode, 'NumberTitle', 'off');
    imshow(BildAB, colormap(jet(256)));
end