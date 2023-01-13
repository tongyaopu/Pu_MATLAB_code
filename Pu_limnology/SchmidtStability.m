function ss = SchmidtStability(depth, rho, area)
%
% stability1 function uses mass method, calculates stability index of a specific
% water column, characterized by a density profile (depth, rho) and
% a hyposograph (depth, area)
%
% Reference: 
%﻿IDSO, S. B. (1973). On the concept of lake stability. Limnology and Oceanography, 18(4), 681–683. https://doi.org/https://doi.org/10.4319/lo.1973.18.4.0681
% eq. 8
% 
% inputs:
%   depth, rho, and area should be vectors with same length
%   depth - depth grid for density profile, 0 at water surface, positive
%   downwards. It should have the same size as rho and area. - m
%   rho - density profile along with depth - kg/m3
%   area - area extend at each depth - m2
%
% outputs:
%   S_massMethod - Schmidt stability J/m2

g = 9.81; % m/s2, constant

A0 = area(1); % m2

zg = trapz(depth, rho .* depth .* area) ./ (trapz(depth, rho .* area)); % center of mass - m

rho_avg = trapz(depth, rho .* area) ./ (trapz(depth, area)); % average density

integrand_massMethod = (depth - zg) .* area .* (rho - rho_avg);

ss = g/A0 * trapz(depth, integrand_massMethod);

end