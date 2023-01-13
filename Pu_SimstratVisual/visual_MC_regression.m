% function [] = visual_MC_regression(MC_analysis_dir, skippingNumber)
MC_analysis_dir = "C:\Users\tongy\Simstrat\TowutiProjects\MC_Oct17\MC_analysis";

% specify yr range so proper index mat file are loaded
% yrRange = [2001 2008];
yrRange = [2009 2016];

cd(MC_analysis_dir);
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
MCName = [char(currentWD_split(end-1)), sprintf('_%d_%d', yrRange(1), yrRange(2))];

% initialize -------------------------------------
% indicatorFiles = dir(sprintf('*.mat'));
indicatorFiles = dir(sprintf('*_%d_%d.mat', yrRange(1), yrRange(2)));
% arrayfun(@(x) load(x.name), indicatorFiles);
for k = 1:length(indicatorFiles)
fn = indicatorFiles(k).name;
load(fn)
end

cd run_configure
updated_mean = readmatrix(dir('*updated_mean.txt').name);
updated_var = readmatrix(dir('*updated_var.txt').name);
cd ..

% updated_mean = updated_mean(1:53, :);
% updated_var = updated_var(1:53, :);


% variables -------------------------------------
ws = updated_mean(:,2);
t = updated_mean(:,4);
vap = updated_mean(:,6);
cloud = updated_mean(:,7);

if exist('skippingNumber', 'var')
    ws(skippingNumber) = [];
    t(skippingNumber) = [];
    vap(skippingNumber) = [];
    cloud(skippingNumber) = [];
end
% plots -----------------------------------------------------------

figure('Position', [100, 80, 900, 500])

subplotRows = 2; subplotColumns = 2;

XaxisNames = {'Wind Speed [m s^{-1}]', ...
    ['Temperature [', char(0176),'C]'], ....
    'Vapor Pressure [mbar]', ...
    'Cloud Cover [1]'};

n = 1; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(ws, NMaxG)
plotRight(ws, WTD)
xlabel(XaxisNames(n))

n = 2; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(t, NMaxG)
plotRight(t, WTD)
xlabel(XaxisNames(n))

n = 3; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(vap, NMaxG)
plotRight(vap, WTD)
xlabel(XaxisNames(n))


n = 4; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(cloud, NMaxG)
plotRight(cloud, WTD)
xlabel(XaxisNames(n))

fn = sprintf('%s.png', MCName);
saveas(gcf, fn)
% end

function plotLeft(var, MSF)
yyaxis left
plot(var, MSF, '*', 'MarkerSize',5, 'LineWidth', 1);
ylabel('MBF [s^{-1}]')
ylim([0, inf])
end

function plotRight(var, WTD)
yyaxis right
plot(var, WTD, 'o', 'MarkerSize',5, 'LineWidth', 1);
ylabel(['WTD [', char(0176),'C]'])
ylim([0, inf])
end