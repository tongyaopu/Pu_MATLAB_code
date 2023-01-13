%function [] = visual_Kz_selection(path2file, profile_year, Tmin, Tmax, ow)

% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti021\LakeTowuti_Outputs", 2004, 23.5, 30)
% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti019\LakeTowuti_Outputs", 2004, 28, 32)
path2file = "C:\Users\tongy\Simstrat\TowutiProjects\Towuti017_5\LakeTowuti_Outputs";
profile_year = 2010;
Tmin = 27; Tmax = 31;
ow = 0;


% change directory to the Simstrat Output folder defined by 'path2file'
% variable ----------------------------------------------------------------
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)

figDir = 'OutputKz_selection';
if exist(figDir, 'dir') && ow == 1
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
temp = readmatrix('T_out.dat'); temp = temp(2:end, 2:end);

% convert time
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');

fprintf('\n START TIME: %s \n END TIME: %s \n', ...
    string(time_datetime(1)), string(time_datetime(end)))
% visualise Kz -----------------------------------------------------------
logKz = log10(Kz);

% % imagesc
% cd (figDir)
% figure 
% colormap(parula(20))
% imagesc(time_dn, depth, logKz'); axis xy
% datetick('x', 'mmm yyyy', 'keeplimits')
% xlabel("Time"); ylabel("Depth")
% title("log(Kz)")
% 
% c = colorbar;
% caxis([-7, 3]);
% c.Label.String = 'm^2/s';
% 
% if min(logKz, [], 'all') < -7 
%     fprintf('min log Kz is %.2f, below colorbar limit \n', min(logKz, [], 'all'))
% end
% if max(logKz, [], 'all') > 3 
%     fprintf('max log Kz is %.2f, exceeding colorbar limit \n', max(logKz, [], 'all'))
% end
% 
% saveas(gcf,sprintf('logKz_%s.png', fName))


%% temperature and Kz profile ------------------------------------------------

interested_time = (datetime(profile_year, 01, 01, 00, 00, 00) : calmonths(1) : datetime(profile_year, 12, 31, 00, 00, 00))';
selectedIndex = datefind(interested_time, time_datetime, 0);
selected_time = time_datetime(selectedIndex);
selectedKzArray = Kz(selectedIndex, :);
selectedlogKzArray = logKz(selectedIndex, :);
selectedTempArray = temp(selectedIndex, :);

figure
imagesc(datenum(selected_time), depth, selectedlogKzArray'); axis xy
c = colorbar; c.Label.String = 'log Kz [m^2 s^{-1}]';
datetick('x', 'mmm','keeplimits')
ylabel('Depth [m]')
axis tight

cd(figDir)
save(sprintf('profiles_%s_%s.mat', fName, string(profile_year)),...
    'selected_time', 'selectedIndex','selectedKzArray', 'selectedlogKzArray', 'selectedTempArray', 'depth');
saveas(gcf, sprintf('profile_Kz_%s_%s.png', fName, string(profile_year)))
cd ..

%% functions ------------------------------------------------
function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end