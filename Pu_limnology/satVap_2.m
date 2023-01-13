function [es] = satVap_2(T)

% T in K

% saturation vapor pressure es_second method
a = 17.2693882; b = 35.86;
es = 6.1078 .* exp(a .*(T - 273.16) ./ (T - b));

end
