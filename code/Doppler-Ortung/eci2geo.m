function [ long, lat ] = eci2geo( nr, WXSAT )
%ECI2GEO Konvertiert Koordinaten vom ECI System in Grad-Angaben
% Schnittstelle:
% i) nr: Nummer der Koordinaten im WXSAT Datensatz
%    WXSAT: geladene WXSAT-Daten
% o) long: Laengengrad
%    lat: Breitengrad


    ECI = WXSAT.positions (nr ,[2 3 4]); % X,Y,Z
    theta = WXSAT.positions (nr ,8);
    x = ECI(1); y = ECI(2); z = ECI(3);

    long = rad2deg(asin(z/sqrt(x^2 + y^2 + z^2)));
    lat = rad2deg(atan(y/x) - theta);
end