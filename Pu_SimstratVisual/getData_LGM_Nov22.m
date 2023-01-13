function [time_datetime, depth, temp, nuh_out, NN_out] = getData_LGM_Nov22(path2file)

% change directory to the Simstrat Output folder defined by 'path2file'
% variable ----------------------------------------------------------------
default_path = pwd; % the original path of where the function is being called.
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)

% name from working directory ---------------------------------------------
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '/'); % '/' in mac, '\' in windows
fName = char(currentWD_split(end));


%% read and convert date ------------------------------------------------
% read any file including time and depth
[temp_table, temp, depth, days] = import_simstrat_outputs('T_out.dat');
nuh_out = readtable('nuh_out.dat');
NN_out = readtable('NN_out.dat');

% convert time
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');

fprintf('simulation start time: %s\n', string(time_datetime(1)));
fprintf('simulation end time: %s\n', string(time_datetime(end)));

cd(default_path) % return back to the path where function is being called.
end

