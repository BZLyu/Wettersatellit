function [ res ] = OffsetKorrektur( Dopplerkurve )
%OFFSETKORREKTUR Entfernt ein DC Offset
% Um das Offset zu entfernen wird der Punkt gesucht, an dem beide Seiten 
% der Spiegelung des Betrags Uebereinstimmen. 
% Schnittstelle:
% i) Dopplerkurve: Vektor mit Y-Werten der Dopplerverschiebung
% o) res: korregierte Version des Eingabe Vektors


    Dopplerkurve = Dopplerkurve - mean(Dopplerkurve);
    
    fun = @(x)mindiff(x, Dopplerkurve);
    x0 = length(Dopplerkurve)/2 - 100;

    % Offset ermitteln, indem der Punkt gesucht wird, an dem die
    % Seiten der gespiegelte Funktion uebereinstimmen.
    offset = fminsearch(fun, x0);
    
    res = Dopplerkurve - offset;

    % Funktion fuer fminsearch
    function res = mindiff(x, Dopplerkurve)

        Dopplerkurve = Dopplerkurve - x;
        [~, Nullstelle] = min(abs(Dopplerkurve));

        res = 0;

        for i = 1:length(Dopplerkurve)/2

            if (Nullstelle-i) <= 0 || (Nullstelle+i) > length(Dopplerkurve)
                break;
            end

            res = res + abs(abs(Dopplerkurve(Nullstelle-i))...
                -abs(Dopplerkurve(Nullstelle+i)));
        end

    end
end
