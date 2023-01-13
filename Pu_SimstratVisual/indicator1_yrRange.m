function [temp_strongest_difference, temp_weakest_difference, NN_max_gradient, NN_mean_gradient] = indicator1_yrRange(path2file, yrRange)


%  simstrat_indicator(path2file) go to the director, read simulation
%  outputs, and extract indicators information, and save it to the
%  ../Indicators folder.
%
%  yrRange = the range of years you want to calculate index from
%
% Possible output variables:
%     'temp_strongest_difference', 'temp_weakest_difference', ...
%     'NN_max_gradient', 'NN_min_gradient', 'NN_mean_gradient', ...
%     'logKz_max', 'logKz_min',...
%     'thermoclineDepth_deepest', 'thermoclineDepth_shallowest')

% change directory to the Simstrat Output folder defined by 'MC_dir' -----
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)

% name from working directory ---------------------------------------------
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '/'); % '/' in mac, '\' in windows
fName = char(currentWD_split(end));


%% Read variables ------------------------------------------------
% read any file including time -------------------------------------------
[table, temp, depth, days] = importDat('T_out.dat');

% convert time -----------------------------------------------------------
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');


fprintf('\n START TIME: %s \n END TIME: %s \n', ...
    string(time_datetime(1)), string(time_datetime(end)))

% read other variables --------------------------------------------------
if isfile('nuh_out.dat')
    Kz = readmatrix('nuh_out.dat');
    Kz = Kz(2:end, 2:end);
    logKz = log10(abs(Kz));
end

if isfile('NN_out.dat')
    NN = readmatrix('NN_out.dat');
    NN = NN(2:end, 2:end);
%    NN = NN(1:length(time_datetime), :);
end



%% temperature and Kz profile ------------------------------------------------

% selection = {'dry season (July) daytime'; 'dry season (July) nighttime'; ...
%     'wet season (Dec) daytime'; 'wet season (Dec) nighttime'};
% dry_dayTime = find(time_datetime >= datetime(profile_year, 7, 01, 12, 00, 00),1);
% dry_nightTime = find(time_datetime >= datetime(profile_year, 7, 02, 00, 00, 00),1);
% wet_dayTime = find(time_datetime >= datetime(profile_year, 12, 01, 12, 00, 00),1);
% wet_nightTime = find(time_datetime >= datetime(profile_year, 12, 02, 00, 00, 00),1);
% 
% selectedIndex = [dry_dayTime; dry_nightTime; wet_dayTime; wet_nightTime];
% selectedlogKzArray = logKz(selectedIndex, :);
% selectedTempArray = temp(selectedIndex, :);


%% Indicators for sensitivity analysis ------------------------------------------------

% find depth larger than 10 m, start there (to avoid interference from the surface)
% find time later than 2000, to avoid interference of initial condition
% z_idx = find(depth < -10);
z_idx = 1: size(temp, 2); % all the z

t_idx = find(time_datetime > datetime(yrRange(1), 12, 31) & time_datetime < datetime(yrRange(2), 12, 31));

fn = sprintf('Indicator_Details_%s.txt', fName);
fileID = fopen(fn,'w');

fprintf(fileID, '\n \n ****** Indicator properties ****** \n');

% INDICATOR 1 -  Minimum and maximum temperature difference --------------
% 

temp_noSurface = temp(t_idx, z_idx);
temp_diff = max(temp_noSurface,[],2) - min(temp_noSurface,[], 2);
temp_weakest_difference = min(temp_diff);
temp_strongest_difference = max(temp_diff);

tt_idx = find (temp_diff == temp_weakest_difference, 1);
datetime_weakest_difference = time_datetime(tt_idx + t_idx(1) - 1);

tt_idx = find (temp_diff == temp_strongest_difference, 1);
datetime_strongest_difference = time_datetime(tt_idx + t_idx(1) - 1);

fprintf(fileID, '\n weakest temperature difference is %.2g, occurs on %s; \n strongest temperature is %.2g, occurs on %s \n',...
    temp_weakest_difference, datetime_weakest_difference, ...
    temp_strongest_difference, datetime_strongest_difference);

% if temp_weakest_difference < 2.1
%     fprintf('%s has temp_diff < 2.1',fName);
% end

% INDICATOR 2 -  Maximum and minimum N2 (below 2 m) ----------------------
%
if exist('NN','var') == 1
    NN_noSurface = NN(t_idx, z_idx);
    NN_max_eachTime = max(NN_noSurface,[],2); % maximum value of each column
    NN_min_gradient = min(NN_max_eachTime); % minimum of maximum value
    NN_max_gradient = max(NN_max_eachTime);
    NN_mean_gradient = mean(NN_max_eachTime);
    
    tt_idx = find (NN_max_eachTime == NN_min_gradient, 1);
    datetime_weakest_gradient = time_datetime(tt_idx + t_idx(1) - 1);
    
    tt_idx = find (NN_max_eachTime == NN_max_gradient, 1);
    datetime_strongest_gradient = time_datetime(tt_idx + t_idx(1) - 1);
    
    fprintf(fileID, '\n weakest maximum N^2 is %.2g, occurs on %s; \n strongest maximum N^2 is %.2g, occurs on %s; \n mean maximum N^2 is %.2g. \n',...
        NN_min_gradient, datetime_weakest_gradient, ...
        NN_max_gradient, datetime_strongest_gradient, ...
        NN_mean_gradient);
end

% INDICATOR 3 -  Maximum and minimum log Kz ------------------------------
%
if exist('logKz','var') == 1
    logKz_noSurface = logKz(t_idx, z_idx);
    logKz_min = min(logKz_noSurface, [], 'all');
    logKz_max = max(logKz_noSurface, [], 'all');
    [tt_idx, zz_idx] = find(logKz_noSurface == logKz_max, 1);
    d1 = depth(zz_idx + z_idx(1) - 1); t1 = time_datetime(tt_idx + t_idx(1) - 1);
    
    [tt_idx, zz_idx] = find(logKz_noSurface == logKz_min, 1);
    d2 = depth(zz_idx +  z_idx(1) - 1); t2 = time_datetime(tt_idx + t_idx(1) - 1);
    
    fprintf(fileID, '\n smallest logKz is %.2g, at t = %s, z = %.2g m; \n largest logKz is %.2g, at t = %s, z = %.2g m; \n', ...
        logKz_min, t1, d1, logKz_max, t2, d2);
end
% INDICATOR 4 - Thermocline (Metamolimnion) depth ----------------------
% 	Below 10 m, 
% 	Do a difference in temperature every 1 m
% 	Find the maximum difference
% 	Find the depth where the maximum temperature difference occurs

temp_diff_everyGrid = temp - circshift(temp, 1, 2); % deeper part minus shallower part
temp_diff_noEdge = temp_diff_everyGrid(t_idx, z_idx(2:end-1));
temp_strongest_gradient = max(abs(temp_diff_noEdge), [], 2);

thermoclineDepth = [];
for i = 1:length(t_idx)
[tt_idx, zz_idx] = find(temp_strongest_gradient(i) == temp_diff_everyGrid(i, :), 1);
thermoclineDepth = [thermoclineDepth; depth(zz_idx + z_idx(1) - 1)];
end
thermoclineDepth_deepest = min(thermoclineDepth);
thermoclineDepth_shallowest = max(thermoclineDepth);

%fprintf('thermocline at %.2g m (strongest temperature gradient below surface 10 m (%.2g) occur at this depth) \n',...
%    thermoclineDepth, temp_strongest_gradient)
fprintf(fileID, '\n Deepest thermocline at %.3g m', thermoclineDepth_deepest);
fprintf(fileID, '\n Shallowest thermocline at %.3g m', thermoclineDepth_shallowest);
% 
% fprintf(fileID, '\n \n ***** INDEXES SUMMARY ****** \n \n');
% fprintf(fileID, '1) Max and min temperature difference: \t stratify = %2g, mix = %.2g \n', temp_strongest_difference, temp_weakest_difference);
% fprintf(fileID, '2) Max and min N^2: \t \t \t stratify = %2g, mix = %.2g \n', NN_max_gradient, NN_min_gradient);
% fprintf(fileID, '3) Max and min logKz: \t \t \t mix = %2g, stratify = %.2g \n', logKz_max, logKz_min);
% fprintf(fileID, '4) Max and min thermocline: \t \t deep = %.3g m, shallow = %.3g m \n', thermoclineDepth_deepest, thermoclineDepth_shallowest);


fclose(fileID);
fn = sprintf('tempInd_%s_%d_%d', fName, yrRange(1), yrRange(2));
save(fn, 'temp_strongest_difference', 'temp_weakest_difference')%, 'thermoclineDepth_deepest', 'thermoclineDepth_shallowest')

if exist('NN','var') == 1
fn = sprintf('NNInd_%s_%d_%d', fName, yrRange(1), yrRange(2));
save(fn, 'NN_max_gradient', 'NN_min_gradient', 'NN_mean_gradient')
end

if exist('logKz','var') == 1
fn = sprintf('KzInd_%s_%d_%d', fName, yrRange(1), yrRange(2));
save(fn, 'logKz_max', 'logKz_min')
end

% fn = sprintf('Indicators_%s.mat', fName);
% save(fn, 'temp_strongest_difference', 'temp_weakest_difference', ...
%     'NN_max_gradient', 'NN_min_gradient', 'NN_mean_gradient', ...
%     'logKz_max', 'logKz_min',...
%     'thermoclineDepth_deepest', 'thermoclineDepth_shallowest')


end

%% functions ------------------------------------------------
function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end