function [ FMDemod ] = FMDemodulation( I, Q )
%FMDEMODULATION Amplitudenfehler Korrektur und FM Demodulation
% Schnittstelle:
% i) I: Vektor mit I-Daten
%    Q: Vektor mit Q-Daten
% o) FMDemod: FM demoduliertes Signal


%% Amplitudenfehler Alpha
alpha = sqrt(sum(Q.^2)/sum(I.^2));
%fprintf('Amplitudenfehler Alpha = %f\n', alpha);
Q=Q./alpha;

%% Auswahl verschiedener Methoden
modulator = 1;
% Programmiert nach: 
% http://kom.aau.dk/group/05gr506/report/node29.html

%% Arctan demodulator
if modulator == 1

    FMDemod = diff(unwrap(atan2(Q, I)));

end

%% Baseband delay demodulator
if modulator == 2

    % Signal muss normiert werden um ein brauchbares Ergebnis zu erhalten.
    Betrag = sqrt(I.^2 + Q.^2);
    Betrag(~Betrag) = 1; % Moegliche Division durch Null verhindern
    I = I./Betrag;
    Q = Q./Betrag;

    FMDemod = asin( (I(1:(end-1)).*Q(2:end))...
                  - (Q(1:(end-1)).*I(2:end)));
       
end

%% Baseband differentiator demodulator
if modulator == 3

    Betrag = sqrt(I.^2 + Q.^2);
    Betrag(~Betrag) = 1;
    I = I./Betrag;
    Q = Q./Betrag;

    FMDemod = (diff(Q).*I(1:end-1))...
           - (diff(I).*Q(1:end-1));

end
end