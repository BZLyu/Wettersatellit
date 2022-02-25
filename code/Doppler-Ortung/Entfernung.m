function [ L ] = Entfernung( b1, l1, b2, l2 )
%ENTFERNUNG Entfernung zwischen zwei Koordinaten in km
% https://de.wikipedia.org/wiki/Luftlinie
% Schnittstelle:
% i) b1, l1, b2, l2: Breiten- und Laengengrade zweier Koordinaten
% o) L: Entfernung in km


    Re=6378.137;     % Erdradius in km

    l1 = deg2rad(l1); 
    b1 = deg2rad(b1); 
    l2 = deg2rad(l2); 
    b2 = deg2rad(b2);
    
    % Oeffnungswinkel
    w = acos(cos(b1)*cos(b2)*cos(l1-l2)+sin(b1)*sin(b2));
    
    L = w*Re;

end