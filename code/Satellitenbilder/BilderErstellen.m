function [ BildA, BildB, AnzahlZeilen, LenBildZeile ]...
    = BilderErstellen( APTDaten, DACSampleFreq )
%BILDERERSTELLEN Zeilensynchronisation und Bildaufbau
% Schnittstelle:
% i) APTDaten: demoduliertes Satellitensignal
%    DACSampleFreq: Abtastfrequenz des Satelliten
% o) BildA: Matrix des Graustufenbildes
%    BildA: Matrix des Infrarotbildes
%    AnzahlZeilen: Zeilenanzahl der Bilder
%    LenBildZeile: Zeilen groesse der Bilder


%% Zeilensynchronisation
SyncA = [0 0 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0];

% Mittelwertfrei
SyncA = SyncA-mean(SyncA);

% Kreuzkorrelation mittels Faltung
SyncKorr = conv(APTDaten, conj(fliplr(SyncA)), 'same');

LenAPTZeile = 0.5*DACSampleFreq;
LenZeileA = 0.25*DACSampleFreq;
LenBildZeile = 47+909+45;
AnzahlZeilen = floor((length(SyncKorr)/LenAPTZeile));

% SyncKorr in Intervalle (Spalten) der Laenge LenAPTZeile einteilen.
SyncKorr = reshape(SyncKorr, [LenAPTZeile, AnzahlZeilen]);

% Spaltenweise Maxima bestimmen
[~, loks] = max(SyncKorr);

% Unbrauchbare Werte am Anfang und Ende entfernen.
% Ist die Differenz der loks null, so haben sie den richtigen Abstand
% voneinander.
DifferenzLoks = diff(loks);
RichtigStart = find(~DifferenzLoks, 1, 'first');
RichtigEnde = find(~DifferenzLoks, 1, 'last');

% Letzte Bildzeile ist nicht mehr in APTDaten enthalten.
%AnzahlZeilen = AnzahlZeilen - 1;
AnzahlZeilen = RichtigEnde - RichtigStart + 1;

%% Bildaufbau
BildA = zeros(AnzahlZeilen, LenBildZeile);
BildB = zeros(AnzahlZeilen, LenBildZeile);

maxval = max(APTDaten(1:LenAPTZeile));
minval = min(APTDaten(1:LenAPTZeile));

for i = 1:AnzahlZeilen
    
    % index ist der Anfang von Space A.
    index = (i+RichtigStart-1)*LenAPTZeile + loks(i+RichtigStart) + 19;
    
    BildA(i,:) = APTDaten(index+1 : index+LenBildZeile);
    BildB(i,:) = APTDaten(index+1+LenZeileA : ...
        index+LenZeileA+LenBildZeile); 

    % Minimum und Maximum durch Mittelwerte von Space A und B bestimmen.
    minvalneu = mean(APTDaten(index+1 : index+45)); % SpaceA    
    maxvalneu = mean(APTDaten(index+1+LenZeileA : ...
        index+LenZeileA+45)); % SpaceB
    
    % Werte bei Minutenmarker nicht verwenden
    if (maxvalneu > 0) && (minvalneu < 0) % kein Minutenmarker
        maxval = maxvalneu;
        minval = minvalneu;
    end
    
    % Werte normieren
    BildA(i,:) = (BildA(i,:)-minval)./(maxval-minval);
    BildB(i,:) = (BildB(i,:)-minval)./(maxval-minval);
end

end

