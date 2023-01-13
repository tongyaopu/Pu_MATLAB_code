clc
clear
close all

path2file = '/Users/tongyaop/Documents/Lake_Towuti/TowutiProjects/Towuti017_5/LakeTowuti_Outputs';
% profile_year = 2012;
% Tmin = 27; Tmax = 31;
ow = 0;


% change directory to the Simstrat Output folder defined by 'path2file'
% variable ----------------------------------------------------------------
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)

figDir = 'simstrat_outputs';
if exist(figDir, 'dir') && ow == 1
    rmdir(figDir,'s')
else
    mkdir(figDir)
end

% switches for figures ----------------------------------------------------
set(0,'DefaultFigureVisible','on')
set(0,'defaultAxesFontSize',20)

% name from working directory ---------------------------------------------
currentWD = pwd;
currentWD_split = strsplit(currentWD, '/'); % '/' in mac, '\' in windows
fName = char(currentWD_split(end));


%% read and convert date ------------------------------------------------
% read any file including time
% [table, Kz, depth, days] = importDat("nuh_out.dat");
% [table, Sal, depth, days] = importDat('S_out.dat');
[temp_table, temp, depth, days] = importDat('T_out.dat');
NN_out = readmatrix('NN_out.dat'); NN_out = NN_out(2:end, 2:end);
Kz = readmatrix('nuh_out.dat'); Kz = Kz(2:end, 2:end);
depth = -depth';

% convert time
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');

fprintf('\n START TIME: %s \n END TIME: %s \n', ...
    string(time_datetime(1)), string(time_datetime(end)))

%% calculate properties
% ----- TDI --------
TDI = TDI_cal(temp);

% ----- MBF(t)-----
MBF = MBF_cal(NN_out);

% --- import Towuti Bathymetry --------------
Bathy = readmatrix('Bathymetry/Bathymetry_AI_linear.dat'); % bathymetry
% data processing
%   depth : 0 at surface, positive downwards, for calculating SS
%   it is also important that the start of the array is at the surface and
%   the end of the array is at the bottom. Probably because the depth_bathy
%   array is ordered that way.
bathy_depth = (-Bathy(:,1));
bathy_area = Bathy(:,2);

% other def
sal = 0; % PSU, constant salinity

prof_depth = flipud(depth); % the depth vector describing obs profiles
bathy_area_itp = interp1(bathy_depth, bathy_area, prof_depth);


% ------ HCI --------------
% ------ SSI --------------

% calculate Schmidt Stability and Heat Content throughout loops
SSI = zeros(length(time_datetime), 1); % store schmidt stability
HCI = zeros(length(time_datetime), 1); % store heat content
for i = 1 :length(time_datetime) % at each time
    temp_profile = flipud((squeeze(temp (i, :)))'); % slice out temperature profile at this time


        % depth in m, 1 m = 1 mbar pressure --> this results in non zero
        % stability while temperature is almost uniform

        % salinity is a constant defined previously, in PSU

        % calculate density (freshwater, chen and miller)
        rho = fw_dens(sal, temp_profile, 0); % g/cm3 calculate (potential) density
        rho = rho * 1e3; % kg/m3

        ss = SchmidtStability(prof_depth, rho, bathy_area_itp);

        hc = HeatContent(prof_depth, temp_profile - 28, bathy_area_itp);

        SSI(i) = ss; HCI(i) = hc;

end

%% plots
figure('Name', 'TD_MBF_HC_SS', 'Position', [0 0 1000 900])
tl = tiledlayout(4, 1);
tl.TileSpacing = 'tight';

nexttile
plot(time_datetime, TDI)
ylabel(['TDI [', char(176) ,'C]'])
set(gca, 'XTickLabel', [])

nexttile
plot(time_datetime, MBF)
ylabel('MBF [s^{-2}]')
set(gca, 'XTickLabel', [])

nexttile
plot(time_datetime, HCI)
ylabel('HCI [J m^{-2}]')
set(gca, 'XTickLabel', [])

nexttile
plot(time_datetime, SSI)
ylabel('SSI [J m^{-2}]')

saveas(gcf, 'simstrat_outputs/TDI_MBF_HC_SS.png')
%% func
function TDI = TDI_cal(temp)
TDI = max(temp, [], 2) - min(temp, [], 2);
end

function MBF = MBF_cal(NN_out)
MBF = max(NN_out, [], 2);
end


function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end