function [Latitude, Longitude, Positionsausgabe] = ...
    DopplerLokalisierung(pathSatellitWav, WXSAT)
%%DOPPLERLOKALISIERUNG Bestimmt die Position des Empfaengers 
% Schnittstelle:
% i) filenamewav:  Pfad zu Wav-Datei 
%    WXSAT: geladene WXSAT-Daten
% o) Latitude: Breitengrad
%    Longitude: Laengengrad
%    Positionsausgabe: Zeichenarray mit der Empfaenger Position

    %% Doppler-Verschiebung auslesen
    SG = Spektrogramm(pathSatellitWav);
    %figure, imagesc(SG);
    Dopplerkurve = KurveExtrahieren(SG);
    clear SG;


    %% Messwerte glaetten und Offset entfernen
    Dopplerkurve = medfilt1(Dopplerkurve, 10);
    Dopplerkurve(1) = Dopplerkurve(2);

    %Dopplerkurve = (6000-125)*(Dopplerkurve - min(Dopplerkurve))/...
    %(max(Dopplerkurve)-min(Dopplerkurve));
    % Kurve1 = Kurve1 - 6000 + 150;

    Dopplerkurve = OffsetKorrektur(Dopplerkurve);


    %% Empfaenger Position ermitteln
    % Ermittelt die Position, indem die Dopplerverschiebung des empfangenen
    % Signales mit fuer verschiedene Koordinaten berechneten 
    % Dopplerverschiebungen verglichen wird.
    
    fun = @(x)mindiff(x(2), x(1), Dopplerkurve, WXSAT);
    x0 = [45, 5];

    options = optimset('TolFun', 1e-7, 'TolX', 1e-7);%'Display','iter',
    bl = fminsearch(fun, x0, options);
    
    Latitude = bl(1);
    Longitude = bl(2);

    %% Position ausgeben
    stLat = 48.747;%7758459;
    stLon = 9.106;%9.1829321;

    Positionsausgabe = sprintf(...
        ['Empfaenger Breitengrad: %.3f, Laengengrad: %f.3\nEntfernung '...
        'zu Stuttgart: %.3f km\n'] , bl(1), bl(2), ...
        Entfernung(bl(1), bl(2), stLat, stLon));

    webmap();
    wmmarker(stLat, stLon, 'FeatureName', 'Stuttgart',...
        'OverlayName', 'Stuttgart');
    wmmarker(bl(1), bl(2), 'FeatureName', 'Ermittelter Wert',...
        'OverlayName', 'Ermittelter Wert');


    %% Dopplerkurven anzeigen
    % figure();
    % hold on;
    % dop = DopplerVerschiebung(stLon, stLat, WXSAT);
    % plot(dop(floor(length(dop)/2-length(Dopplerkurve)/2+1):...
    %     floor(length(dop)/2+length(Dopplerkurve)/2)));
    % plot(Dopplerkurve, 'g')


    %% Funktion fuer fminsearch
    % Berechnet den Unterschied zwischen zwei Doppler-Verschiebungen
    function res = mindiff(l, b, DopplerSatellit, WXSAT)

        DopplerBerechnet = DopplerVerschiebung(l, b, WXSAT);

        nm = length(DopplerSatellit);
        nd = length(DopplerBerechnet);

        res = sum(abs(DopplerSatellit...
            - DopplerBerechnet(floor(nd/2-nm/2+1):floor(nd/2+nm/2))));
    end
end