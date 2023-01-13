%function [] = visual_EV_2(EV_dir)
EV_dir = "C:\Users\tongy\Simstrat\TowutiProjects\EV_May1\EV_simulations";
set(0,'defaultAxesFontSize',16)

nrun = 10; nvar = 4; % change according to simulation

%  simstrat_indicator(EV_dir, dir_ID) go through folders identified with
%  'identifier' under 'EV_dir' directory, read simulation output files, and
%  extract indicators information (defined in methodology part of my
%  thesis), and save it to and EV_dir/Indicators directory.
%  The saved mat file can be used in the Monte Carlo Analysis
%
% Inputs:
%   EV_dir: directory to Monte Carlo simslations. This directory should
%   contain subfolders of each run. This directory contains multiple
%   folders but only folders identified with identifier will be accessed
%
%   identifier: a char/str that identifies the folders that contain
%   simulation information of each runs. This is to separate out other
%   directory that is not used as Simstrat simulation. E.g, identifier =
%   'TowutiOutput' will read folders which has name 'TowutiOutput' at the
%   front.
%
%

% change directory to the Simstrat Output folder defined by 'EV_dir' -----
fprintf('Folder: %s \n', EV_dir); mustBeFolder(EV_dir)
cd(EV_dir)

% name from EV directory ---------------------------------------------
currentWD = pwd;
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
EVName = char(currentWD_split(end));

listing = dir('TowutiOutput_*');

EV_varName = strings([length(listing), 1]);
EV_varMean = zeros(length(listing),1);
EV_WTD = zeros(length(listing),1);
EV_WTD = zeros(length(listing),1);
EV_NMaxG = zeros(length(listing),1);
EV_NavgG = zeros(length(listing),1);
EV_storage  = zeros(nrun * nvar, 2 + 4);

% created a storage matrix
%   rows - total simulation numbers,

for i = 1: length(listing)
    EVInfo = listing(i).name;
    EVInfo_split = strsplit(EVInfo, '_');
    varName = string(EVInfo_split(end - 1)); % the variable name from the simulation folder
    varMean_char = cell2mat(EVInfo_split(end));
    varMean = sscanf(varMean_char, '%f'); % the variable mean from the simulation folder
    
    [temp_strongest_difference, temp_weakest_difference, NN_max_gradient, NN_mean_gradient] = ...
        indicator1(EVInfo);
    cd ..
    switch varName % convert varName to varNum for storage
        case 'wind'
            varNum = 2;
        case 't'
            varNum = 4;
        case 'vap'
            varNum = 6;
        case 'cloud'
            varNum = 7;
    end
    EV_varName(i)= varName;
    EV_varMean(i) = varMean;
    EV_WTD(i) = temp_strongest_difference;
    EV_WTD(i) = temp_weakest_difference;
    EV_NMaxG(i) = NN_max_gradient;
    EV_NavgG(i) = NN_mean_gradient;
    EV_storage(i, :) = [varNum, varMean, temp_strongest_difference, temp_weakest_difference, NN_max_gradient, NN_mean_gradient];
    fprintf('Currently on %s, mean %.2g \n', varName, varMean)
end


idx_wind = find(EV_varName == 'wind');
idx_t = find(EV_varName == 't');
idx_vap = find(EV_varName == 'vap');
idx_cloud = find(EV_varName == 'cloud');


figure('Position', [0, 0, 1500, 400])

subplotRows = 2; subplotColumns = 2;

XaxisNames = {'Wind Speed [m s^{-1}]', ...
    ['Temperature [', char(0176),'C]'], ....
    'Vapor Pressure [mbar]', ...
    'Cloud Cover [1]'};

n = 1; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_wind), EV_NMaxG(idx_wind))
plotRight(EV_varMean(idx_wind), EV_WTD(idx_wind))
xlabel(XaxisNames(n))

n = 2; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_t), EV_NMaxG(idx_t))
plotRight(EV_varMean(idx_t), EV_WTD(idx_t))
xlabel(XaxisNames(n))

n = 3; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_vap), EV_NMaxG(idx_vap))
plotRight(EV_varMean(idx_vap), EV_WTD(idx_vap))
xlabel(XaxisNames(n))


n = 4; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_cloud), EV_NMaxG(idx_cloud))
plotRight(EV_varMean(idx_cloud), EV_WTD(idx_cloud))
xlabel(XaxisNames(n))


cd ../EV_analysis
save('EV_storage', 'EV_storage')
save('EV_variables', 'EV_varName', 'EV_varMean', 'EV_WTD', 'EV_WTD', 'EV_NMaxG','EV_NavgG')
fn = sprintf('%s.png', EVName);
saveas(gcf, fn)
cd ..


function plotLeft(var, MSF)
yyaxis left
plot(var, MSF, '*', 'MarkerSize',12, 'LineWidth', 3);
ylabel('MBF [s^{-1}]')
ylim([0, 8E-4])
end

function plotRight(var, WTD)
yyaxis right
plot(var, WTD, 'o', 'MarkerSize',12, 'LineWidth', 3);
ylabel(['WTD [', char(0176),'C]'])
ylim([0, 2])
end



