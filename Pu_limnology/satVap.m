function [es] = satVap(T)

% T in K

es0 = 6.11; %hpa - saturation vap pressure @ ref temp
T0 = 273.15; %K - reference temp
L = 2.5e6; % J/kg - latent heat of evaporation of water
Rw = 461.52; % J/kgK - specfic gas constant

es = es0 .* exp(L ./ Rw .* (1/T0 - 1./T));

end