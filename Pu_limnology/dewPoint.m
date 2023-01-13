function Td = dewPoint(T, vap)
% \cite{monteithChapterPropertiesGases2013}
% T - current temperature in kelvin
% e - current vapor pressure
% need satVap calculator

A = 18.3; % A depend on T A = λMw/RT∗.  λ = 2470 J g−1 K−1
Td = T .* 1 - 1./A .* (log(vap./satVap(T)));
end