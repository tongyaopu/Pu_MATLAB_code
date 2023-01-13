function rhoMax = fw_rhoMax(S, P)
% fw_rhoMax is a function that calculates the maximum density in g cm-3
% Ref: Chen_Millero_1986
% it takes input of 
% S - salinity in g kg-1
% P - dbar
% chen and millero

% convert P from dbar to bar
P = P .* 0.1;

rhoMax = 0.9999720 + 4.94686 .* 1e-5 .* P - ...
    2.0918 .* 1e-9 .* P .^2 + ...
    (8.0357 .* 1e-4 + 1e-7 .* P) .* S;