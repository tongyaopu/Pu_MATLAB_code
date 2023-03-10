function rho = fw_dens(S, T, P)

% fw_dens(S, T, P) determines freshwater density rho from S, T, and P, which can be in
% forms of matrix. Ref: Chen_Millero_1986
%
% rho - density [g cm-3]
% S - salinity [g/kg]
% T - temperature [°C]
% P - pressure [dbar]
%
% Chen_Millero_1986

% convert P [dbar] input by user to [bar] used in the paper
P = P .* 1e-1;

% Eq. 2 calculate rho0 [g cm-2]
rho0 = 0.9998395 + 6.7914 .* 1e-5 .* T - ...
    9.0894 .* 1e-6 .* T .^2 + ...
    1.0171 .* 1e-7 .* T.^3 - ...
    1.2846 .* 1e-9 .* T .^4 + ...
    1.1592 * 1e-11 .* T.^5 - ...
    5.0125 .* 1e-14 .* T .^6 + ...
    (8.181 .* 1e-4 - 3.85 .*1e-6 .* T + 4.96 .* 1e-8 .* T .^2) .* S; 

% Eq. 3 calculate K [bar]
K = 19652.17 + 148.113 .* T - ... 
    2.293 .* T .^ 2 + ...
    1.256 .* 1e-2 .* T .^3 - ...
    4.18 .* 1e-5 .* T .^4 + ...
    (3.2726 - 2.147 .* 1e-4 .* T + 1.128 .* 1e-4 .* T .^ 2) .* P + ...
    (53.238 - 0.313 .* T + 5.728 .* 1e-3 .* P) .* S;

% Eq. 1 calculate rho at pressure P
rho = rho0 .* (1 - P ./K) .^ (-1);

end