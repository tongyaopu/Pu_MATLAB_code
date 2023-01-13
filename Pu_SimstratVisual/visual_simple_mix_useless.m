function [] = visual_MIXprofile(path2file, profile_year, Tmin, Tmax, OverWriteFlag)

% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti021\LakeTowuti_Outputs", 2004, 23.5, 30)
% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti019\LakeTowuti_Outputs", 2004, 28, 32)



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

% figure position matrix -----------------------------------------
TempFigPositionMatrix =  [0, 0, 1000, 400];
TempFigPositionMatrix =  [0, 0, 1000, 800];
TempProfFigPositionMatrix =  [0, 0, 500, 800];

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

figDir = 'OutputFigures';
if exist(figDir, 'dir') && OverWriteFlag == 1
    rmdir(figDir,'s')
end
mkdir(figDir)


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
[table, Sal, depth, days] = importDat('S_out.dat');
[table, temp, depth, days] = importDat('T_out.dat');
NN_out = readtable('NN_out.dat');


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
cd (figDir)
figure 
colormap(parula(20))
imagesc(time_dn, depth, logKz'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel("Time"); ylabel("Depth")
title("log(Kz)")

c = colorbar;
caxis([-7, 3]);
c.Label.String = 'm^2/s';

if min(logKz, [], 'all') < -7 
    fprintf('min log Kz is %.2f, below colorbar limit \n', min(logKz, [], 'all'))
end
if max(logKz, [], 'all') > 3 
    fprintf('max log Kz is %.2f, exceeding colorbar limit \n', max(logKz, [], 'all'))
end

saveas(gcf,sprintf('logKz_%s.png', fName))


%% salinity ---------------------------------------------------------------


figure
colormap parula(20)
imagesc(time_dn, depth, Sal'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel('Time'); ylabel('Depth')
title(['Salinity [PSU]'])

c = colorbar; c.Label.String = ['PSU'];

llim = 0.077; hlim = 0.079; % low and high limit of salinity
caxis([llim, hlim]);
if min(Sal, [], 'all') < llim
    fprintf('min Sal is %.4f, below colorbar limit \n', min(Sal, [], 'all'))
end
if max(Sal, [], 'all') > hlim
    fprintf('max Sal is %.4f, exceeding colorbar limit \n', max(Sal, [], 'all'))
end

saveas(gcf, sprintf('Salinity_%s.png', fName))


%% Temperature ------------------------------------------------------------

temp = temp(1:length(time_datetime), :);

figure('Position', TempFigPositionMatrix)
 % imagesc plot
colormap parula(50)

imagesc(time_dn, depth, temp'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel('Time'); ylabel('Depth')
title(['Temperature ' ,char(176),'C'])

c = colorbar; c.Label.String = [char(176),'C'];
caxis([Tmin, Tmax]);
if min(temp, [], 'all') < Tmin
    fprintf('min Temp is %.2f, below colorbar limit', min(temp, [], 'all'))
end
if max(temp, [], 'all') > Tmax
    fprintf('max Temp is %.2f, exceeding colorbar limit \n', max(temp, [], 'all'))
end

saveas(gcf, sprintf('tempImagesc_%s.png', fName))


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

saveas(gcf, sprintf('tempPlot_%s.png', fName))

%% calculate WTD index, and get time index

% find time later than 2000, to avoid interference of initial condition
z_idx = find(depth < -10);
t_idx = find(time_datetime > datetime(2001, 12, 31));

fn = sprintf('Indicator_Details_%s.txt', fName);
fileID = fopen(fn,'w');

fprintf(fileID, '\n \n ****** Indicator properties ****** \n');

% INDICATOR 1 -  Minimum and maximum temperature difference --------------
% 
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
selection = ["weakestTempDifferenceProfiles"];
% selection = {'dry season (July) daytime'; 'dry season (July) nighttime'; ...
%     'wet season (Dec) daytime'; 'wet season (Dec) nighttime'};
% dry_dayTime = find(time_datetime >= datetime(profile_year, 7, 01, 12, 00, 00),1);
% dry_nightTime = find(time_datetime >= datetime(profile_year, 7, 02, 00, 00, 00),1);
% wet_dayTime = find(time_datetime >= datetime(profile_year, 12, 01, 12, 00, 00),1);
% wet_nightTime = find(time_datetime >= datetime(profile_year, 12, 02, 00, 00, 00),1);
% 
% selectedIndex = [dry_dayTime; dry_nightTime; wet_dayTime; wet_nightTime];
selectedIndex = WTD_idx;
selectedlogKzArray = logKz(selectedIndex, :);
selectedTempArray = temp(selectedIndex, :);

save(sprintf('profiles_%s_%s.mat', fName, string(profile_year)),...
    'selection', 'selectedIndex','selectedlogKzArray', 'selectedTempArray', 'depth');


% observation - model temperature comparison ------------------------------------------------
figure('Position', TempProfFigPositionMatrix)

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
saveas(gcf,sprintf('tempComp_%s_%s.png', fName, string(profile_year)))

%% how about NN ------------------------------------------------
NN_out = table2array(NN_out(2:end, 2:end));
NN_out = NN_out(1:length(time_datetime), :);

NN_max_profile = max(NN_out,[],2); % maximum value of each column

NN_min_series = min(NN_max_profile); % minimum of maximum value
[x, y] = find(NN_out == NN_min_series);

%log_NN_out = log10(abs(NN_out));

figure
plot(time_datetime, NN_max_profile)
xlabel('Time'); ylabel('N^2 [s^{-2}]')
ylim([0 4e-3])
saveas(gcf,sprintf('NNGradient_plot_%s.png', fName))

figure
imagesc(time_dn, depth, NN_out'); axis xy;
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel('Time'); ylabel('Depth [m]')

c = colorbar;
caxis([0, 0.5e-3])
c.Label.String = 'N^2 [s^{-2}]';
hlim = 0.5e-3;
if max(NN_out, [], 'all') > hlim
    fprintf('max NN is %.2g, exceeding colorbar limit \n', max(NN_out, [], 'all'))
end
saveas(gcf,sprintf('NN_%s.png', fName))
 cd  ..
%% ------------------------------------------------
% eps_out = readtable('eps_out.dat');
% eps_out = table2array(eps_out(2:end, 2:end));
% log_eps_out = log10(eps_out);
% 
% figure
% imagesc(time_dn, depth, log_eps_out'); axis xy;
% datetick('x', 'mmm yyyy', 'keeplimits')
% 
% c = colorbar;
% llim = -14; hlim = 4;
% caxis([llim hlim])
% if min(log_eps_out, [], 'all') < llim
%     fprintf('min log_eps_out is %.3g, below colorbar limit \n', min(log_eps_out, [], 'all'))
% end
% if max(log_eps_out, [], 'all') > hlim
%     fprintf('max log_eps_out is %.3g, exceeding colorbar limit \n', max(log_eps_out, [], 'all'))
% end
% c.Label.String = 's^{-2}';
% %title('log eps')
% saveas(gcf,sprintf('logEps_%s.png', fName))

% %% Indicators for sensitivity analysis ------------------------------------------------
% % notice the depth and time that being indexed are not correct
% 
% % find Depth at 10, start there (to avoid interference from the surface)
% z_idx = find(depth < -10);
% % find time later than 2000, avoid interference of initial condition
% t_idx = find(time_decyear > 2002);
% 
% fn = sprintf('IndicatorDetails_%s.txt', fName);
% fileID = fopen(fn,'w');
% 
% fprintf(fileID, '\n \n ****** Indicator properties ****** \n');
% % INDICATOR 1 -  Minimum and maximum temperature difference
% temp_noSurface = temp(t_idx, z_idx);
% temp_diff = max(temp_noSurface,[],2) - min(temp_noSurface,[], 2);
% temp_weakest_difference = min(temp_diff);
% temp_strongest_difference = max(temp_diff);
% 
% tt_idx = find (temp_diff == temp_weakest_difference, 1);
% datetime_weakest_difference = time_datetime(tt_idx + t_idx(1) - 1);
% 
% tt_idx = find (temp_diff == temp_strongest_difference, 1);
% datetime_strongest_difference = time_datetime(tt_idx + t_idx(1) - 1);
% 
% fprintf(fileID, '\n weakest temperature difference is %.2g, occurs on %s; \n strongest temperature is %.2g, occurs on %s \n',...
%     temp_weakest_difference, datetime_weakest_difference, ...
%     temp_strongest_difference, datetime_strongest_difference);
% 
% % INDICATOR 2 -  Maximum and minimum N2 (below 2 m)
% 
% NN_noSurface = NN_out(t_idx, z_idx);
% NN_max_eachTime = max(NN_noSurface,[],2); % maximum value of each column
% NN_min_gradient = min(NN_max_eachTime); % minimum of maximum value
% NN_max_gradient = max(NN_max_eachTime);
% NN_mean_gradient = mean(NN_max_eachTime);
% 
% tt_idx = find (NN_max_eachTime == NN_min_gradient, 1);
% datetime_weakest_gradient = time_datetime(tt_idx + t_idx(1) - 1);
% 
% tt_idx = find (NN_max_eachTime == NN_max_gradient, 1);
% datetime_strongest_gradient = time_datetime(tt_idx + t_idx(1) - 1);
% 
% fprintf(fileID, '\n weakest maximum N^2 is %.2g, occurs on %s; \n strongest maximum N^2 is %.2g, occurs on %s \n',...
%     NN_min_gradient, datetime_weakest_gradient, ...
%     NN_max_gradient, datetime_strongest_gradient);
% 
% % INDICATOR 3 -  Maximum and minimum log Kz
% logKz_noSurface = logKz(t_idx, z_idx);
% logKz_min = min(logKz_noSurface, [], 'all');
% logKz_max = max(logKz_noSurface, [], 'all');
% [tt_idx, zz_idx] = find(logKz_noSurface == logKz_max, 1);
% d1 = depth(zz_idx + z_idx(1) - 1); t1 = time_datetime(tt_idx + t_idx(1) - 1);
% 
% [tt_idx, zz_idx] = find(logKz_noSurface == logKz_min, 1);
% d2 = depth(zz_idx +  z_idx(1) - 1); t2 = time_datetime(tt_idx + t_idx(1) - 1);
% 
% fprintf(fileID, '\n smallest logKz is %.2g, at t = %s, z = %.2g m; \n largest logKz is %.2g, at t = %s, z = %.2g m; \n', ...
%     logKz_min, t1, d1, logKz_max, t2, d2);
% 
% % INDICATOR 4 - Thermocline (Metamolimnion) depth :
% % 	Below 10 m, 
% % 	Do a difference in temperature every 1 m
% % 	Find the maximum difference
% % 	Find the depth where the maximum temperature difference occurs
% 
% temp_diff_everyGrid = temp - circshift(temp, 1, 2); % deeper part minus shallower part
% temp_diff_noEdge = temp_diff_everyGrid(t_idx, z_idx(2:end-1));
% temp_strongest_gradient = max(abs(temp_diff_noEdge), [], 2);
% plot(temp_strongest_gradient)
% 
% thermoclineDepth = [];
% for i = 1:length(t_idx)
% [tt_idx, zz_idx] = find(temp_strongest_gradient(i) == temp_diff_everyGrid(i, :), 1);
% thermoclineDepth = [thermoclineDepth; depth(zz_idx + z_idx(1) - 1)];
% end
% thermoclineDepth_deepest = min(thermoclineDepth);
% thermoclineDepth_shallowest = max(thermoclineDepth);
% %fprintf('thermocline at %.2g m (strongest temperature gradient below surface 10 m (%.2g) occur at this depth) \n',...
% %    thermoclineDepth, temp_strongest_gradient)
% fprintf(fileID, '\n Deepest thermocline at %.3g m', thermoclineDepth_deepest);
% fprintf(fileID, '\n Shallowest thermocline at %.3g m', thermoclineDepth_shallowest);
% 
% fprintf(fileID, '\n \n ***** INDEXES SUMMARY ****** \n \n');
% fprintf(fileID, '1) Max and min temperature difference: \t stratify = %2g, mix = %.2g \n', temp_strongest_difference, temp_weakest_difference);
% fprintf(fileID, '2) Max and min N^2: \t \t \t stratify = %2g, mix = %.2g \n', NN_max_gradient, NN_min_gradient);
% fprintf(fileID, '3) Max and min logKz: \t \t \t mix = %2g, stratify = %.2g \n', logKz_max, logKz_min);
% fprintf(fileID, '4) Max and min thermocline: \t \t deep = %.3g m, shallow = %.3g m \n', thermoclineDepth_deepest, thermoclineDepth_shallowest);
% 
% fclose(fileID);
% 
% fn = sprintf('Indicators_%s.mat', fName);
% save(fn, 'temp_strongest_difference', 'temp_weakest_difference', ...
%     'NN_max_gradient', 'NN_min_gradient', 'NN_mean_gradient', ...
%     'logKz_max', 'logKz_min',...
%     'thermoclineDepth_deepest', 'thermoclineDepth_shallowest')


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