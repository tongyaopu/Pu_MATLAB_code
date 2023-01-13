% function [] = visual_simple(path2file, profile_year, Tmin, Tmax, ow)

% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti021\LakeTowuti_Outputs", 2004, 23.5, 30)
% visual_simple("/Users/tongyaop/Documents/Lake_Towuti/TowutiProjects/LGM_varBathy/LGM_simulations/TowutiOutput_Bathymetry_AI_linear_100m", 2004, 20, 32, 1)

path2file = '/Users/tongyaop/Documents/Lake_Towuti/TowutiProjects/Towuti017_5/LakeTowuti_Outputs';
profile_year = 2012;
Tmin = 27; Tmax = 31;
ow = 0;

% TempPositionMatrix =  [0, 0, 1000, 400];
TempPositionMatrix =  [0, 0, 1000, 800];
TempProfPositionMatrix =  [0, 0, 500, 800];

% simstratVisual_simple(path2file, profile_year) visualises simstrat
% simulation outputs specified by path2file, and plot temperature profiles
% (during wet/dry season day/night time) during profile_year, and compare
% it to observational profiles (under the SimstratVisual/ package directory)
%
% Inputs:
%   path2file: a string specify the path to Output/ folder
%   profile_year: an integer specify the interested year to plot
%   Tmin: lower limit used in temperature plots
%   Tmax: upper limit used in temperature plots
% Outputs:
%   figures are saved in Output/ folder

% INITIALIZING CTD PROFILES -----------------------------------------------
% load observation file first (under MATLAB_FUNCTION_DIR/SimstratVisual/)
load CTDs_observation.mat CTDs
load CTDs_datestr.mat obs_datestr
load RC_temp_data.mat RC_depth RC_time RC_temp

CTD_fields = fieldnames(CTDs);
CTD_fieldValue = struct2cell(CTDs);

% setup color gradient for later uses
% len = length(CTD_fields);
% younger = [222, 222, 222]/255; % orange
% older = [13, 13, 13]/255; %blue
% colors_p = [linspace(younger(1),older(1),len)', linspace(younger(2),older(2),len)', linspace(younger(3),older(3),len)'];

% line_color = ["#2A87AD", "#122C4A", "#B50000", "#690A0A"]; % too dark
% line_color = ["#1B90F6", "#2B5ADC", "#DB163A", "#8F001A"];


% change directory to the Simstrat Output folder defined by 'path2file'
% variable ----------------------------------------------------------------
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)

figDir = 'simstrat_outputs';
if exist(figDir, 'dir') && ow == 1
    rmdir(figDir,'s')
end
mkdir(figDir)


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
depth = -depth;

% convert time
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');

fprintf('\n START TIME: %s \n END TIME: %s \n', ...
    string(time_datetime(1)), string(time_datetime(end)))

%% visualise Kz -----------------------------------------------------------
logKz = log10(abs(Kz));

% imagesc
figure ('Name','Kz', 'Position',[0 0 1000 900])
% colormap(parula(20))
imagesc(time_dn, depth, logKz'); %axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xtickangle(20)
ylim([0 200])
ylabel("Depth [m]")
% title("log(Kz)")

c = colorbar;
clim([-7, 3]);
c.Label.String = 'log_{10}(Kz) [m^2/s]';

if min(logKz, [], 'all') < -7
    fprintf('min log Kz is %.2f, below colorbar limit \n', min(logKz, [], 'all'))
end
if max(logKz, [], 'all') > 3
    fprintf('max log Kz is %.2f, exceeding colorbar limit \n', max(logKz, [], 'all'))
end

saveas(gcf,sprintf('simstrat_outputs/logKz_%s.png', fName))

%% visualize Temperature ------------------------------------------------------------
figure('Position', [0 0 1000 900])
% imagesc plot
% colormap parula(50)
imagesc(time_dn, depth, temp'); %axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xtickangle(20)
ylim([0 200])
ylabel("Depth [m]")
% title(['Temperature ' ,char(176),'C'])
c = colorbar; c.Label.String = ['Temperature [', char(176),'C]'];
clim([Tmin, Tmax]);
if min(temp, [], 'all') < Tmin
    fprintf('min Temp is %.2f, below colorbar limit', min(temp, [], 'all'))
end
if max(temp, [], 'all') > Tmax
    fprintf('max Temp is %.2f, exceeding colorbar limit \n', max(temp, [], 'all'))
end

saveas(gcf, sprintf('simstrat_outputs/tempImagesc_%s.png', fName))

fig_tempLinePlt = 0;
if fig_tempLinePlt
    figure % lineplot

    idx = 1 : 40:  length(depth);
    depth2 = depth(idx);

    % %setup color gradient for later uses
    % len = length(depth2);
    % younger = [222, 222, 222]/255; % orange
    % older = [13, 13, 13]/255; %blue
    % colors_p = [linspace(younger(1),older(1),len)', linspace(younger(2),older(2),len)', linspace(younger(3),older(3),len)'];
    % colororder(colors_p)

    plot(time_datetime, temp(:, idx))
    xlabel('Time'); ylabel('Depth')
    legend(string(depth2))
    title(['Temperature ' ,char(176),'C'])

    ylim([Tmin, Tmax]);

    if min(temp, [], 'all') < Tmin
        fprintf('min Temp is %.2f, below colorbar limit', min(temp, [], 'all'))
    end
    if max(temp, [], 'all') > Tmax
        fprintf('max Temp is %.2f, exceeding colorbar limit \n', max(temp, [], 'all'))
    end

    saveas(gcf, sprintf('simstrat_outputs/tempPlot_%s.png', fName))
end

%% temperature and Kz selected profile ------------------------------------------------
swth_profile = 0
if swth_profile
    selection = {'dry season (July) daytime'; 'dry season (July) nighttime'; ...
        'wet season (Dec) daytime'; 'wet season (Dec) nighttime'};
    dry_dayTime = find(time_datetime >= datetime(profile_year, 7, 01, 12, 00, 00),1);
    dry_nightTime = find(time_datetime >= datetime(profile_year, 7, 02, 00, 00, 00),1);
    wet_dayTime = find(time_datetime >= datetime(profile_year, 12, 01, 12, 00, 00),1);
    wet_nightTime = find(time_datetime >= datetime(profile_year, 12, 02, 00, 00, 00),1);

    selectedIndex = [dry_dayTime; dry_nightTime; wet_dayTime; wet_nightTime];
    selectedlogKzArray = logKz(selectedIndex, :);
    selectedTempArray = temp(selectedIndex, :);

    save(sprintf('profiles_%s_%s.mat', fName, string(profile_year)),...
        'selection', 'selectedIndex','selectedlogKzArray', 'selectedTempArray', 'depth');


    % observation - model temperature comparison ------------------------------------------------
    figure('Position', TempProfPositionMatrix)

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
    saveas(gcf,sprintf('simstrat_outputs/tempComp_%s_%s.png', fName, string(profile_year)))
end
%% how about NN ------------------------------------------------

figure('Name','N2', 'Position',[0 0 1000 900])
imagesc(time_dn, depth, NN_out'); %axis xy;
datetick('x', 'mmm yyyy', 'keeplimits')
xtickangle(20)
ylim([0 200])
ylabel("Depth [m]")

c = colorbar;
clim([0, 0.5e-3])
c.Label.String = 'N^2 [s^{-2}]';
hlim = 0.5e-3;
if max(NN_out, [], 'all') > hlim
    fprintf('max NN is %.2g, exceeding colorbar limit \n', max(NN_out, [], 'all'))
end
saveas(gcf,sprintf('simstrat_outputs/NN_%s.png', fName))


 %% functions ------------------------------------------------
function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end