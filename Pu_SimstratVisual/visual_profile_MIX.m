function [] = visual_profile_MIX(path2file, profile_year, Tmin, Tmax)


% simstratVisual_simple(path2file, profile_year) visualises simstrat
% simulation outputs specified by path2file, and plot temperature profiles
% (during wet/dry season day/night time) during profile_year, and compare
% it to observational profiles (under the SimstratVisual/ package directory)
%
% Inputs:
%   path2file: a string specify the path to Output/ folder
%   profile_year: an integer specify the interested year to plot
%   Tmin: lower ,limit used in temperature plots
%   Tmax: upper limit used in temperature plots
%   dryN: dry season month number

% Outputs:
%   figures are saved in Output/ folder

% INITIALIZING CTD PROFILES -----------------------------------------------
% load observation file first (under MATLAB_FUNCTION_DIR/SimstratVisual/)
load CTDs_observation.mat CTDs
load CTDs_datestr.mat obs_datestr

CTD_fields = fieldnames(CTDs);
CTD_fieldValue = struct2cell(CTDs);

% setup color gradient for later uses
len = length(CTD_fields);
younger = [222, 222, 222]/255; % orange
older = [13, 13, 13]/255; %blue
colors_p = [linspace(younger(1),older(1),len)', linspace(younger(2),older(2),len)', linspace(younger(3),older(3),len)'];

line_color = ["#2A87AD", "#122C4A", "#B50000", "#690A0A"]; % too dark
line_color = ["#1B90F6", "#2B5ADC", "#DB163A", "#8F001A"];


% change directory to the Simstrat Output folder defined by 'path2file'
% variable ----------------------------------------------------------------
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)


% Get a list of all files and folders in this folder.
files = dir(path2file);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip . and ..
% Optional fun : Print folder names to command window.
for k = 1 : length(subFolderNames)
    fprintf('Sub folder #%d = %s\n', k, subFolderNames{k});
end



% create Outputfigures folder
figDir = 'OutputFigures';
if ~exist(figDir, 'dir')
    mkdir(figDir)
end

% switches for figures ----------------------------------------------------
set(0,'DefaultFigureVisible','on')
set(0,'defaultAxesFontSize',14)

% name from working directory ---------------------------------------------
currentWD = pwd;
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
fName = char(currentWD_split(end));


%% read and convert date ------------------------------------------------
% read any file including time
[table, Kz, depth, days] = importDat("nuh_out.dat");

% convert time
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');

fprintf('\n START TIME: %s \n END TIME: %s \n', ...
    string(time_datetime(1)), string(time_datetime(end)))
% visualise Kz -----------------------------------------------------------^
%logKz = log10(abs(Kz));
logKz = log10(Kz);
%% Temperature ------------------------------------------------------------

[table, temp, depth, days] = importDat('T_out.dat');
temp = temp(1:length(time_datetime), :);

%% find WTD 

% find time later than 2000, to avoid interference of initial condition
z_idx = find(depth < -10);
t_idx = find(time_datetime > datetime(profile_year, 01, 01));

fn = sprintf('Indicator_Details_%s.txt', fName);
fileID = fopen(fn,'w');
fprintf(fileID, '\n \n ****** Indicator properties ****** \n');

temp_noSurface = temp(t_idx, z_idx);
temp_diff = max(temp_noSurface,[],2) - min(temp_noSurface,[], 2);
temp_weakest_difference = min(temp_diff);
temp_strongest_difference = max(temp_diff);

WTD_tt_idx = find (temp_diff == temp_weakest_difference, 1);
WTD_idx = WTD_tt_idx + t_idx(1);
datetime_weakest_difference = time_datetime(WTD_tt_idx + t_idx(1) - 1);

MTD_tt_idx = find (temp_diff == temp_strongest_difference, 1);
MTD_idx = MTD_tt_idx + t_idx(1);
datetime_strongest_difference = time_datetime(MTD_tt_idx + t_idx(1) - 1);

fprintf(fileID, '\n weakest temperature difference is %.2g, occurs on %s; \n strongest temperature is %.2g, occurs on %s \n',...
    temp_weakest_difference, datetime_weakest_difference, ...
    temp_strongest_difference, datetime_strongest_difference);


%% temperature and Kz profile ------------------------------------------------

% dryM = datestr(datetime(1,dryN,1),'mmmm'); % dry season month name
% wetM = datestr(datetime(1,wetN,1),'mmmm'); % dry season month name
% 
% selection = {sprintf('dry season (%s) daytime', dryM); ...
%     sprintf('dry season (%s) nighttime', dryM); ...
%     sprintf('wet season (%s) daytime', wetM);
%     sprintf('wet season (%s) nighttime', wetM)};
% 
% dry_dayTime = find(time_datetime >= datetime(profile_year, dryN, 01, 12, 00, 00),1);
% dry_nightTime = find(time_datetime >= datetime(profile_year, dryN, 02, 00, 00, 00),1);
% wet_dayTime = find(time_datetime >= datetime(profile_year, wetN, 01, 12, 00, 00),1);
% wet_nightTime = find(time_datetime >= datetime(profile_year, wetN, 02, 00, 00, 00),1);
selection = ["weakestTempDifferenceProfiles"];
selectedIndex = WTD_idx;
% selectedIndex = [dry_dayTime; dry_nightTime; wet_dayTime; wet_nightTime];
selectedlogKzArray = logKz(selectedIndex, :);
selectedTempArray = temp(selectedIndex, :);

% plot selected profile
figure
grid on
for i = 1 : length(selection)
    % temperature plot
    subplot(2, length(selection), i)
    plot(selectedTempArray(i,:), depth, '-r','LineWidth', 3)
    xlabel(['Temperature [', char(176) ,'C]']);
    ylabel('Depth [m]');
    subplot(2, length(selection), length(selection) + i)
    plot(selectedlogKzArray(i,:), depth, '-k','LineWidth', 3)
    xlabel('Kz [m^2 s^{-1}]');
    ylabel('Depth [m]')
end

cd(figDir)
saveas(gcf, sprintf('profiles_%s_%s.png', fName, string(profile_year)))
saveas(gcf, sprintf('profiles_%s_%s.fig', fName, string(profile_year)))

save(sprintf('profiles_%s_%s.mat', fName, string(profile_year)),...
    'selection', 'selectedIndex','selectedlogKzArray', 'selectedTempArray', 'depth');
cd ..

% observation - model temperature comparison ------------------------------------------------

figure
% plot observational profiles
for i = 1 : length(CTD_fields)
    colororder(colors_p)
    data =  CTDs.(CTD_fields{i}); % data of the selected year, n x 3 array
    CTD_depth = -data(:,1);
    CTD_temp = data(:,2);
    plot(CTD_temp, CTD_depth, 'LineWidth', 4); %axis ij
    hold on
end

% plot selected temperatre profiles
for i = 1 : length(selection)
    plot(selectedTempArray(i,:), depth, 'LineWidth', 3, 'Color', line_color(i))
    hold on
end

% other plot settings
xlim([Tmin Tmax])
grid minor
legText = [obs_datestr; string(selection)];
xlabel(['Temperature [', char(176) ,'C]']); ylabel('Depth [m]')
legend(legText, 'Location','southeast', 'FontSize', 10)

cd(figDir)
saveas(gcf,sprintf('tempComp_%s_%s.png', fName, string(profile_year)))
saveas(gcf,sprintf('tempComp_%s_%s.fig', fName, string(profile_year)))

cd ..


%% close and clear figures and variables generated by this function. This
% does not clear global variables -----------------------------------------
% close all
clear

end

%% functions ------------------------------------------------
function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end