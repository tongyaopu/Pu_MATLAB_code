function t_MD = fw_TMD(S, P)
% fw_TMD is a function that calculates the temperature at maximum density 
% Ref: Chen_Millero_1986
% it takes input of 
% S - salinity in g kg-1
% P - dbar

% convert P from dbar to bar
P = P .* 0.1;
t_MD =  3.9839 - 1.9911 .* 1e-2 .* P - ...
    5.822 .*  1e-6 .* P .^ 2 - ...
    (0.2219 + 1.106 .* 1e-4 .* P) .* S;