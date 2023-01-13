function [] = visual_EV(EV_analysis_dir)

% visual_EV("C:\Users\tongy\Simstrat\TowutiProjects\EV_May1\EV_analysis")

cd(EV_analysis_dir);
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
EVName = char(currentWD_split(end-1));

% initialize -------------------------------------
cd run_configure
load EV_variables
% plots -----------------------------------------------------------

idx_wind = find(EV_varName == 'wind');
idx_t = find(EV_varName == 't');
idx_vap = find(EV_varName == 'vap');
idx_cloud = find(EV_varName == 'cloud');



figure('Position', [100, 80, 900, 500])

subplotRows = 2; subplotColumns = 2;

XaxisNames = {'Wind Speed [m s^{-1}]', ...
    ['Temperature [', char(0176),'C]'], ....
    'Vapor Pressure [mbar]', ...
    'Cloud Cover [1]'};

n = 1; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_wind), EV_NMaxG(idx_wind))
plotRight(EV_varMean(idx_wind), EV_MTD(idx_wind))
xlabel(XaxisNames(n))

n = 2; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_t), EV_NMaxG(idx_t))
plotRight(EV_varMean(idx_t), EV_MTD(idx_t))
xlabel(XaxisNames(n))

n = 3; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_vap), EV_NMaxG(idx_vap))
plotRight(EV_varMean(idx_vap), EV_MTD(idx_vap))
xlabel(XaxisNames(n))


n = 4; % plot number
subplot(subplotRows, subplotColumns, n)
plotLeft(EV_varMean(idx_cloud), EV_NMaxG(idx_cloud))
plotRight(EV_varMean(idx_cloud), EV_MTD(idx_cloud))
xlabel(XaxisNames(n))

cd ..
fn = sprintf('%s.png', EVName);
saveas(gcf, fn)
cd ..


end

function plotLeft(var, MSF)
yyaxis left
plot(var, MSF, '*', 'MarkerSize',12, 'LineWidth', 3);
ylabel('N^2')
ylim([0, inf])
end

function plotRight(var, MTD)
yyaxis right
plot(var, MTD, 'o', 'MarkerSize',12, 'LineWidth', 3);
ylabel(['t [', char(0176),'C]'])
ylim([0, inf])
end



