% function [] = visual_keps(path2file, ow)

% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti021\LakeTowuti_Outputs", 2004, 23.5, 30)
% visual_simple("C:\Users\tongy\Simstrat\TowutiProjects\Towuti019\LakeTowuti_Outputs", 2004, 28, 32)

% simstratVisual_k-eps  - takes input of k, epsilon, nuh (diffusivity of
% temperature), num (viscosity of momentum). calculate if diffusivity
% matches the approximation from k2/eps
%
% Inputs: 
%   path2file: a string specify the path to Output/ folder
% Outputs:
%   figures are saved in Output/ folder
path2file = "C:\Users\tongy\Simstrat\TowutiProjects\Towuti017_3\LakeTowuti_Outputs";
ow = 1;
profile_year = 2008;

% change directory to the Simstrat Output folder defined by 'path2file'
% variable ----------------------------------------------------------------
fprintf('Folder: %s \n', path2file); mustBeFolder(path2file)
cd(path2file)

figDir = 'OutputFigures';
if exist(figDir, 'dir') && ow == 1
    rmdir(figDir,'s')
end
mkdir(figDir)


% switches for figures ----------------------------------------------------
set(0,'DefaultFigureVisible','on')
set(0,'defaultAxesFontSize',14)
% figure location setting
%TempPositionMatrix =  [0, 0, 1000, 400];
TempPositionMatrix =  [0, 0, 1000, 800];
TempProfPositionMatrix =  [0, 0, 500, 800];


% name from working directory ---------------------------------------------
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
fName = char(currentWD_split(end));


%% read and convert date ------------------------------------------------
% read any file including time
[table, Kz_temp_modeled, depth, days] = importDat("nuh_out.dat");
Kz_momentum_modeled = readmatrix("num_out.dat", 'NumHeaderLines', 1);
Kz_momentum_modeled = Kz_momentum_modeled(:, 2:end);
k = readmatrix("k_out.dat", 'NumHeaderLines', 1);
k = k(:, 2:end); % get rid of time column
eps = readmatrix("eps_out.dat", 'NumHeaderLines', 1);
eps = eps(:, 2:end);
NN_out = readmatrix('NN_out.dat', 'NumHeaderLines', 1);
NN_out = NN_out(:, 2:end);


% convert time
start_dn = datenum(1900, 01, 01, 00, 00, 00);
time_days = days; % days after 1900. This is defined by ERA forcing
time_dn = start_dn + time_days;
time_datetime = datetime(time_dn, 'convertfrom', 'datenum');

fprintf('\n START TIME: %s \n END TIME: %s \n', ...
    string(time_datetime(1)), string(time_datetime(end)))

% visualise Kz -----------------------------------------------------------
logKz_temp_modeled = log10(abs(Kz_temp_modeled));
logKz_momentum_modeled = log10(Kz_momentum_modeled);
% imagesc

fignuh = figure; 
colormap(parula(20))
imagesc(time_dn, depth, logKz_temp_modeled'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel("Time"); ylabel("Depth")
title("log(Kz), diffusivity for temperature")

c = colorbar;
caxis([-7, 3]);
c.Label.String = 'm^2/s';

if min(logKz_temp_modeled, [], 'all') < -7 
    fprintf('min log Kz is %.2f, below colorbar limit \n', min(logKz_temp_modeled, [], 'all'))
end
if max(logKz_temp_modeled, [], 'all') > 3 
    fprintf('max log Kz is %.2f, exceeding colorbar limit \n', max(logKz_temp_modeled, [], 'all'))
end

cd (figDir)
saveas(gcf,sprintf('logKzTemp_%s.png', fName))
cd ..

fignum = figure; 
colormap(parula(20))
imagesc(time_dn, depth, logKz_momentum_modeled'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel("Time"); ylabel("Depth")
title("log(Kz), viscosity for momentum")

c = colorbar;
caxis([-7, 3]);
c.Label.String = 'm^2/s';

cd (figDir)
saveas(gcf,sprintf('logKzMom_%s.png', fName))
cd ..

%% calculate viscosity according to Goudsmit 2002
c_mu = 0.09;
nu = 1.5e-6; % m2/s, molecular diffusivity of momentum

c_mu_prime = 0.072;
nu_prime = 1.5e-7; %m2/s, molecular diffsivity of temperature

nu_t = c_mu .* k.^2 ./ eps; % turbulent diffusivity / viscosity of momentum
Kz_momentum_cal = nu + nu_t; 
logKz_momentum_cal = log10(Kz_momentum_cal);

nu_t_prime = c_mu_prime * k .^2 ./ eps; % turbulent diffusivity of temperature
Kz_temp_cal = nu_prime + nu_t_prime;
logKz_temp_cal = log10(Kz_temp_cal);


% imagesc

fignumcal = figure; 
colormap(parula(20))
imagesc(time_dn, depth, logKz_momentum_cal'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel("Time"); ylabel("Depth")
title("log(Kz), viscosity of momentum, calculated")
c = colorbar;
caxis([-7, 3]);
c.Label.String = 'm^2/s';

fignuhcal = figure;
colormap(parula(20))
imagesc(time_dn, depth, logKz_temp_cal'); axis xy
datetick('x', 'mmm yyyy', 'keeplimits')
xlabel("Time"); ylabel("Depth")
title("log(Kz), diffusivity of temperature, calculated")
c = colorbar;
caxis([-7, 3]);
c.Label.String = 'm^2/s';

cd (figDir)
saveas(fignumcal, sprintf('logKzMomCal_%s.png', fName))
saveas(fignuhcal, sprintf('logKzTempCal_%s.png', fName))
cd ..
%% selection ------------------------------------------------

selection = {'dry season (July) daytime'; 'dry season (July) nighttime'; ...
    'wet season (Dec) daytime'; 'wet season (Dec) nighttime'};
dry_dayTime = find(time_datetime >= datetime(profile_year, 7, 22, 12, 00, 00),1);
dry_nightTime = find(time_datetime >= datetime(profile_year, 7, 22, 00, 00, 00),1);
wet_dayTime = find(time_datetime >= datetime(profile_year, 12, 01, 12, 00, 00),1);
wet_nightTime = find(time_datetime >= datetime(profile_year, 12, 02, 00, 00, 00),1);

selectedIndex = [dry_dayTime];% dry_nightTime; wet_dayTime; wet_nightTime];
% selected Kz, k-eps profile
selectedlogKzTemp = logKz_temp_modeled(selectedIndex,:);
selectedlogKzTemp_cal = logKz_temp_cal(selectedIndex,:);
selectedlogKzMom = logKz_momentum_modeled(selectedIndex,:);
selectedlogKzMom_cal = logKz_momentum_cal(selectedIndex,:);

figKzComp = figure;
plot(selectedlogKzTemp, depth);
hold on
plot(selectedlogKzTemp_cal, depth);
hold on
plot(selectedlogKzMom, depth);
hold on
plot(selectedlogKzMom_cal, depth);
xlabel('logKz [m^2 s^{-1}]')
ylabel('Depth [m]')
legend(["Kz temp modeled", "Kz temp calculated", "Kz momentum modeled", "Kz momentum calculated"], ...
    Location="northwest")
cd(figDir)
saveas(figKzComp, sprintf('KzComp_%s.png', fName));
cd ..

save(sprintf('profiles_KzComp_%s_%s.mat', fName, string(profile_year)),...
    'selection', 'selectedIndex','selectedlogKzTemp', ...
    'selectedlogKzTemp_cal', 'selectedlogKzMom_cal', 'depth');


%% close and clear figures and variables generated by this function. This
% does not clear global variables -----------------------------------------
% close all 
%clear



%% functions ------------------------------------------------
function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end