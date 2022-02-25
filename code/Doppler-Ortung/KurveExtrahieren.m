function [ Result ] = KurveExtrahieren( Spektrogramm )
%KURVEEXTRAHIEREN Extrahiert die Doppler-Verschiebung
% Liest die Frequenz-Kurve aus, indem fuer jede Spalte das Maximum in einem
% Such-Bereich bestimmt wird. Der Such-Bereich wird um den vorherigen Wert
% ausgewaehlt.
% Schnittstelle:
% i) Spektrogramm: Matrix des Spektrogrammes 
% o) Result:  Vektor mit Y-Werten der Dopplerverschiebung

    [SGX, SGY] = size(Spektrogramm);
    
    Start = 100;
    Ende = 100;
    
    Result = zeros(SGY - Start - Ende, 1);
    
    % Breite des Such-Bereiches des Maxima
    AuswahlGr = 140;
    
    
    % Startwert fuer Kurve in der Mitte bestimmen
    [~, nullpos] = max(Spektrogramm(5000,:));
    [~, StartWert] = max(Spektrogramm(...
        5000-AuswahlGr/2 : 5000+AuswahlGr/2, nullpos));
    
    StartWert = StartWert + (5000-200);
    
    WertAlt = StartWert;
    Result(nullpos-Ende) = StartWert;
    
    for i=nullpos:SGY-Ende
        
        if (WertAlt-AuswahlGr/2)<=0 || (WertAlt+AuswahlGr/2) > SGX
            error('Fehler');
        end
        
       [~, WertNeu] = max(Spektrogramm(...
           WertAlt-AuswahlGr/2 : WertAlt+AuswahlGr/2, i));
  
        WertNeu = WertNeu + (WertAlt-AuswahlGr/2);
        
        Result(i-Start) = WertNeu;
        WertAlt = WertNeu;
    end
    
    WertAlt = StartWert;
    
   for i=nullpos:-1:Start
       
        if (WertAlt-AuswahlGr/2)<=0 || (WertAlt+AuswahlGr/2) > SGX
            error('Fehler');
        end
        
        [~, WertNeu] = max(Spektrogramm(...
            WertAlt-AuswahlGr/2 : WertAlt+AuswahlGr/2, i));

        WertNeu = WertNeu + (WertAlt-AuswahlGr/2);
        
        Result(i-Start+1) = WertNeu;
        WertAlt = WertNeu; 
   end
end