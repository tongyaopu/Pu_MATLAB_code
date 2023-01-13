function colors_p = gradientColorScheme(dataGroupVector, startColorCode, endColorCode)

% gradientColorScheme function creats a color matrix that can be used to
% generate a discrete color gradient used to plot vectors that have
% continuous relationships, for example, a progression of time or depth.
%
% dataGroupVector defines how many vectors there are to be ploted
% startColor and endColor are 1*3 vectors defines color. e.g. [222, 222,
% 222] gives orange
% 
% output: colors_p a length(dataGroupVector) by 3 matrix. to use it as plot
% color scheme, simply call colororder(colors_p)

%setup color gradient
len = length(dataGroupVector);
younger = startColorCode ./255; % orange
older = endColorCode ./255; %blue
colors_p = [linspace(younger(1),older(1),len)', linspace(younger(2),older(2),len)', linspace(younger(3),older(3),len)'];
colororder(colors_p)