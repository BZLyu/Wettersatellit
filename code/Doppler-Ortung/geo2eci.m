function [ Pos ] = geo2eci( lon, lat, alt, angle_sid )
%GEO2ECI Konvertiert Koordinaten von Grad-Angaben in das ECI System
% adaptiert von:
% https://idlastro.gsfc.nasa.gov/ftp/pro/astro/geo2eci.pro
% Schnittstelle:
% i) lon: Laengengrad
%    lat: Breitengrad
%    alt: Hoehe in km
%    angle_sid: Sternzeiz
% o) Pos:  Vektor mit Position im ECI-System in km


    Re  = 6378.137;  % Erdradius in km

    lat = deg2rad(lat);
    lon = deg2rad(lon);

    theta=lon+angle_sid; % azimuth
    r=(alt+Re)*cos(lat);
    X=r*cos(theta);
    Y=r*sin(theta);
    Z=(alt+Re)*sin(lat);
    
    Pos = [X, Y, Z];
end