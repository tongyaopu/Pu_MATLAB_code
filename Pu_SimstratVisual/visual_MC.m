%function [] = visual_MC(MC_analysis_dir, skippingNumber)

MC_analysis_dir = ("C:\Users\tongy\Simstrat\TowutiProjects\MC_May1\MC_analysis")
set(0,'defaultAxesFontSize',16)


cd(MC_analysis_dir);
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
MCName = char(currentWD_split(end-1));

% initialize -------------------------------------
indicatorFiles = dir('*.mat');
% arrayfun(@(x) load(x.name), indicatorFiles);
for k = 1:length(indicatorFiles)
fn = indicatorFiles(k).name;
load(fn)
end

cd run_configure
updated_mean = readmatrix(dir('*updated_mean.txt').name);
updated_var = readmatrix(dir('*updated_var.txt').name);
cd ..

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

figure('Position', [0, 0, 1500, 400])

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


function plotLeft(var, MSF)
yyaxis left
plot(var, MSF, '*', 'MarkerSize',12, 'LineWidth', 3);
ylabel('MBF [s^{-1}]')
ylim([0, inf])
end

function plotRight(var, WTD)
yyaxis right
plot(var, WTD, 'o', 'MarkerSize',12, 'LineWidth', 3);
ylabel(['WTD [', char(0176),'C]'])
ylim([0, inf])
end