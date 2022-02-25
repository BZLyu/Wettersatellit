function [ f ] = DopplerVerschiebung( l, b, WXSAT )
%DOPPLERVERSCHIEBUNG Berechnen der Dopplerverschiebung 
% Schnittstelle:
% i) l: Laengengrad 
%    b: Breitengrad
%    WXSAT: geladene WXSAT-Daten
% o) f: Vektor mit Y-Werten der berechneten Dopplerverschiebung

    [AnzPos, ~] = size(WXSAT.positions);
    f = zeros(AnzPos, 1);
    f0 = WXSAT.frequency;
    c = physconst('LightSpeed')/1000;

    for i=1:AnzPos

        position = geo2eci(l, b, 0.5, WXSAT.positions(i, 8));  
        %plot3(stuttgart(1),stuttgart(2),stuttgart(3),'bo')

        % Normalenvektor in Richtung Empfaenger.
        SB = position - WXSAT.positions(i, [2 3 4]);
        E = SB./norm(SB);
        
        VS = WXSAT.positions(i, [5 6 7]);

        %plot3(WXSAT.positions(i, 2),WXSAT.positions(i, 3),WXSAT.positions(i, 4),'ro')
        f(i) = f0*(1+(E*VS.')/c);
        f(i) = f(i)-f0;
    end

end