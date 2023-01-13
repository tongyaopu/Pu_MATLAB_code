
function HC = HeatContent(depth, temp, bathy_area)

% The HeatContent function calculates the heat content of a water column by
% integrating the cp * rho * (Tf - Ti) by depth. Ti = 0 degree C
% (assuming S = 0, P = dep in dbar)

cp = 4186; % J/kg/C
rho_w = fw_dens(0, temp, depth) * 1000 ; % kg m-3
HC = trapz(depth, cp .* rho_w .* temp .* bathy_area) ./ bathy_area(1); 

