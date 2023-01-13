% function [] = visual_MC_yrRange_comparison(MC_analysis_dir, skippingNumber)

% MC_analysis_dir = "C:\Users\tongy\Simstrat\TowutiProjects\MC_Oct17\MC_analysis";
MC_analysis_dir = "/Users/tongyaop/Documents/Lake_Towuti/TowutiProjects/LGM_Nov22/LGM_analysis/";

% specify yr range so proper index mat file are loaded
% yrRange = [2001 2008];
yrRange = [2001 2008];
yrRange = [2009 2016];

cd(MC_analysis_dir);
currentWD = pwd;
currentWD_split = strsplit(currentWD, '/'); % '/' in mac, '\' in windows
MCName = [char(currentWD_split(end-1))];%, sprintf('_%d_%d', yrRange(1), yrRange(2))];

% initialize -------------------------------------
% indicatorFiles = dir(sprintf('*.mat'));
% indicatorFiles = dir(sprintf('*_%d_%d.mat', yrRange(1), yrRange(2)));
indicatorFiles = dir('*.mat');

% arrayfun(@(x) load(x.name), indicatorFiles);
for k = 1:length(indicatorFiles)
    fn = indicatorFiles(k).name;
    % load(fn)
    fn_split = strsplit(fn, '.');
    fn_front = char(fn_split(1));
    indicators.(fn_front) = importdata(fn);
end

% plots -----------------------------------------------------------
figure('Position', [0 0 1000 400])
nplotrow = 1;
nplotcolumn = 2;
subplot(nplotrow, nplotcolumn, 1)
plot(indicators.WTD_MC_simulations_2001_2008, indicators.WTD_MC_simulations_2009_2016, ...
    'o')
plot(indicators.WTD_MC_simulations_2001_2008, indicators.WTD_MC_simulations_2001_2008, '-k')% add 1:1 line
xlabel('WTD pre 2008'); ylabel('WTD post 2009')
axis square

% subplot(nplotrow, nplotcolumn, 2)
% plot(indicators.NAvgG_MC_simulations_2001_2008, indicators.NAvgG_MC_simulations_2009_2016, ...
%     '*')
% plot(indicators.NAvgG_MC_simulations_2001_2008, indicators.NAvgG_MC_simulations_2001_2008, '-k')% add 1:1 line
% xlabel('avgBF pre 2008'); ylabel('avgMBF post 2009')
% axis square

subplot(nplotrow, nplotcolumn, 2)
plot(indicators.NMaxG_MC_simulations_2001_2008, indicators.NMaxG_MC_simulations_2009_2016, ...
    '*')
plot(indicators.NMaxG_MC_simulations_2001_2008, indicators.NMaxG_MC_simulations_2001_2008, '-k')% add 1:1 line
xlabel('MBF pre 2008'); ylabel('MBF post 2009')
axis square

fn_fig = sprintf('%s_yrRangeComparison.png', MCName);
saveas(gcf, fn_fig)
fn_fig = sprintf('%s_yrRangeComparison.fig', MCName);
saveas(gcf, fn_fig)

% count mixing points ------------------------------------------------
pre2008mixing = sum(indicators.WTD_MC_simulations_2001_2008 <= 0.04);
post2009mixing = sum(indicators.WTD_MC_simulations_2009_2016 <= 0.04);
% end % function end

