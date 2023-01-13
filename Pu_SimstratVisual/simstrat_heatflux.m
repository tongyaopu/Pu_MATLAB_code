% this doc visualizes heatflux calculated by simstrat, plus solar radiation
% orginally from ERA5 input (* 0.8)

cd /Users/tongyaop/Documents/Lake_Towuti/InputOrganize_Towuti/Forcing_cleaned/ERA5_2022_v3/ERA5_matrix/
load('ERA5_Mar2022v7_wtp.mat','Forcing_short_table')
sol = Forcing_short_table.sol;
t_era5 = Forcing_short_table.time;
t_era5_dt = datetime(t_era5 + datenum(1900,01,01),'ConvertFrom', 'datenum');
% IMPORTANT!! sol = 0.8 .* sol(idx_t);

cd /Users/tongyaop/Documents/Lake_Towuti/TowutiProjects/Towuti017_5/LakeTowuti_Outputs
HA_out = readmatrix("HA_out.dat");
HK_out = readmatrix("HK_out.dat");
HV_out = readmatrix("HV_out.dat");
HW_out = readmatrix("HW_out.dat");

t = HA_out(2:end,1);
t_dt = datetime(t + datenum(1900,01,01), 'ConvertFrom', 'datenum');
HA_out = HA_out(2:end,2);% HA Long-wave radiation from sky
HW_out = HW_out(2:end,2);% HW Long-wave radiation from water
HK_out = HK_out(2:end,2);% HK Sensible heat flux
HV_out = HV_out(2:end,2);% HV Latent heat flux

% subset sol
idx_t = zeros(length(t), 1);
for i = 1:length(t)
    idx_t(i) = find(t(i) <= t_era5, 1);
end
length(idx_t)
sol = 0.8 * 0.92 .* sol(idx_t);
% t_era52 = t_era5(idx_t); % double check

%% plot
% close all
fig_together = 0;
if fig_together
    set(0, 'DefaultAxesFontSize', 20)

    rangelow = find(t_dt == datetime(2008,01,01));
    rangehigh = find(t_dt == datetime(2010,12,31));
    interval = 12; %2;

    clr = [54, 52, 50; 25, 103, 116; 240, 148, 31; 239, 96, 36;  185, 38, 18]./255;
    % syb = {'-','--',':','-.', '-'};
    syb = {'-','-','-','-', '-'};

    % plot together
    figure ('Name','simstrat heat flux', 'Position', [0 0 900 400])
    plot(t_dt(rangelow:interval:rangehigh), HA_out(rangelow:interval:rangehigh), ...
        char(syb(1)), 'Color', clr(1,:), 'LineWidth',3);
    hold on
    % yline(mean(HA_out(rangelow:interval:rangehigh)), 'r')
    plot(t_dt(rangelow:interval:rangehigh), HW_out(rangelow:interval:rangehigh), ...
        char(syb(2)), 'Color', clr(2,:), 'LineWidth',3);
    plot(t_dt(rangelow:interval:rangehigh), HK_out(rangelow:interval:rangehigh), ...
        char(syb(3)), 'Color', clr(3,:), 'LineWidth',3);
    plot(t_dt(rangelow:interval:rangehigh), HV_out(rangelow:interval:rangehigh), ...
        char(syb(4)), 'Color', clr(4,:), 'LineWidth',3);
    legend({'Long-wave radiation from sky';
        'Long-wave radiation from water';
        'Sensible heat flux'
        'Latent heat flux'}, 'Location','southoutside','FontSize',14, 'NumColumns',2);
    set(gca, 'YGrid', 'on', 'XGrid', 'off')
    ylim([-500 500])
    grid minor
    % char(syb(1))
    saveas(gcf, 'outputs/simstratHF_oneplt.png')
end
%% tile plot
close all
set(0, 'DefaultAxesFontSize', 20)

figure ('Name','simstrat heat flux', 'Position', [0 0 700 1000])

% clr = [54, 52, 50; 25, 103, 116; 240, 148, 31; 239, 96, 36;  185, 38, 18]./255;
% clr = repelem(0, 5, 3);
clr = repelem([19, 103, 138]./255, 6,1);
% syb = {'-','--',':','-.', '-'};
syb = {'-','-','-','-', '-'};
lw = 2; % linewidth
txtclr = 'k';

rangelow = find(t_dt == datetime(2012,01,01));
rangehigh = find(t_dt == datetime(2012,12,31));
interval = 12; %2;


tl = tiledlayout(6, 1); % shortwave radiation
tl.TileSpacing = 'tight';
nexttile
plot(t_dt(rangelow:interval:rangehigh), sol(rangelow:interval:rangehigh), '-k', HandleVisibility='off');
% ylim([0 250])
xticks([datetime(2012, 01,01): calmonths(1): datetime(2012,12,31)])
set(gca,'XTickLabel',[]);
% shading wet and dry season
hold on
shadeSeasons
hold on
plot(t_dt(rangelow:interval:rangehigh), sol(rangelow:interval:rangehigh), ...
    char(syb(5)), 'Color', clr(5,:), 'LineWidth',lw);
% dummyh = line(nan, nan, 'Linestyle', 'none', 'Marker', 'none', 'Color', 'none');
% legend('Shortwave', 'Location','southeast')
text('Units', 'Normalized', 'Position', [1, 0.1], ...
    'HorizontalAlignment', 'right', 'FontSize', 18, 'Color', txtclr, ...
    'string', 'Shortwave')


nexttile % longwave in
plot(t_dt(rangelow:interval:rangehigh), HA_out(rangelow:interval:rangehigh),'-k','HandleVisibility','off');
% ylabel('LW in')
% ylim([325 425])
xticks([datetime(2012, 01,01): calmonths(1): datetime(2012,12,31)])
set(gca,'XTickLabel',[]);
hold on
shadeSeasons
hold on
plot(t_dt(rangelow:interval:rangehigh), HA_out(rangelow:interval:rangehigh), ...
    char(syb(1)), 'Color', clr(1,:), 'LineWidth',lw);
% legend('Longwave in', 'Location','southeast')
text('Units', 'Normalized', 'Position', [1, 0.1], ...
    'HorizontalAlignment', 'right', 'FontSize', 18, 'Color', txtclr, ...
    'string', 'Longwave in')

nexttile %longwave out
plot(t_dt(rangelow:interval:rangehigh), HW_out(rangelow:interval:rangehigh), '-k');
% ylim([-465 -450])
hold on
shadeSeasons
hold on
plot(t_dt(rangelow:interval:rangehigh), HW_out(rangelow:interval:rangehigh), ...
    char(syb(2)), 'Color', clr(2,:), 'LineWidth',lw);
% legend('Longwave out', 'Location','southeast')
xticks([datetime(2012, 01,01): calmonths(1): datetime(2012,12,31)])
set(gca,'XTickLabel',[]);
text('Units', 'Normalized', 'Position', [1, 0.1], ...
    'HorizontalAlignment', 'right', 'FontSize', 18, 'Color', txtclr, ...
    'string', 'Longwave out')


nexttile % sensible
plot(t_dt(rangelow:interval:rangehigh), HK_out(rangelow:interval:rangehigh), '-k','HandleVisibility','off');
% ylim([-125 -25])
xticks([datetime(2012, 01,01): calmonths(1): datetime(2012,12,31)])
set(gca,'XTickLabel',[]);
hold on
shadeSeasons
hold on
plot(t_dt(rangelow:interval:rangehigh), HK_out(rangelow:interval:rangehigh), ...
    char(syb(3)), 'Color', clr(3,:), 'LineWidth',lw);
% legend('Sensible Heat', 'Location','southeast')
text('Units', 'Normalized', 'Position', [1, 0.1], ...
    'HorizontalAlignment', 'right', 'FontSize', 18, 'Color', txtclr, ...
    'string', 'Sensible Heat')

nexttile % latent
plot(t_dt(rangelow:interval:rangehigh), HV_out(rangelow:interval:rangehigh), '-k', 'HandleVisibility','off');
xticks([datetime(2012, 01,01): calmonths(1): datetime(2012,12,31)])
set(gca,'XTickLabel',[]);
hold on
shadeSeasons
hold on
plot(t_dt(rangelow:interval:rangehigh), HV_out(rangelow:interval:rangehigh), ...
    char(syb(4)), 'Color', clr(4,:), 'LineWidth',lw);
% legend('Latent Heat', 'Location','southeast')
text('Units', 'Normalized', 'Position', [1, 0.1], ...
    'HorizontalAlignment', 'right', 'FontSize', 18, 'Color', txtclr, ...
    'string', 'Latent Heat')

% legend({'Long-wave radiation from sky';
%  'Long-wave radiation from water';
% 'Sensible heat flux'
% 'Latent heat flux'}, 'Location','southoutside','FontSize',14, 'NumColumns',2);
% set(gca, 'YGrid', 'on', 'XGrid', 'off')
% ylim([-500 500])
% grid minor
% char(syb(1))

net = sol + HA_out + HW_out + HK_out + HV_out;

% net =  sol(rangelow:interval:rangehigh) + HA_out(rangelow:interval:rangehigh) +  HW_out(rangelow:interval:rangehigh) +  HK_out(rangelow:interval:rangehigh) +  HV_out(rangelow:interval:rangehigh);
nexttile % net flux
plot(t_dt(rangelow:interval:rangehigh), net(rangelow:interval:rangehigh), '-k')
hold on
shadeSeasons
hold on
plot(t_dt(rangelow:interval:rangehigh), net(rangelow:interval:rangehigh), 'Color', clr(6,:),'LineWidth',lw)
% legend({'Net',''}, 'Location','southeast')
hold on
yline(0, '--','LineWidth',2, HandleVisibility='off')
text('Units', 'Normalized', 'Position', [1, 0.1], ...
    'HorizontalAlignment', 'right', 'FontSize', 18, 'Color', txtclr, ...
    'string', 'Net')
xtickangle(45)
xticks([datetime(2012, 01,01): calmonths(1): datetime(2012,12,31)])
set(gca,'XMinorTick','on')

tl.YLabel.String = 'Heat Fluxes [W m^{-2}]';
tl.YLabel.FontSize = 22;
saveas(gcf, 'outputs/simstratHF_tlplt.png')

%% integrate net heat flux
yr = 2010; % 2008 has most negative surface heat, 2.6e5 kJ
rangelow = find(t_dt == datetime(yr,09,01));
rangehigh = find(t_dt == datetime(yr,12,31));
netflux_thisRange_kJ = trapz(datenum(t_dt(rangelow:rangehigh)), net(rangelow:rangehigh) .* 3600 .* 24 .* 1e-3) % Wm-2 * seconds per day * time length -> kJoule m-2 per time length
netflux_wholeSim_kJ = trapz(datenum(t_dt), net.*3600.*24 .* 1e-3);

% functions ===========
function shadeSeasons

% find wet season and dry season
% sulaweisi monsoon rains fall between November and April, while from May to October there is the dry season
% simstrat observed - July to October and the wet season lasts from November to next May.

wt_st = 04; wt_end = 10;
% wt = [datetime(2007,wt_st,15) datetime(2007,wt_end,15);
%     datetime(2008,wt_st,15) datetime(2008,wt_end,15)];
% dr = [datetime(2007,01,01) datetime(2007,wt_st,15);
%     datetime(2007,wt_end,15) datetime(2008,wt_st,15);
%     datetime(2008,wt_end,15) datetime(2008,12,31)];

wt = [datetime(2012,wt_st,15) datetime(2012,wt_end,15)];
dr = [datetime(2012,01,01) datetime(2012,wt_st,15);
    datetime(2012,wt_end,15) datetime(2012,12,31)];

% dr_color = [255, 172, 61]./255;
% wt_color = [42, 178, 255]./255;
wt_color = [0, 0, 1];
dr_color = [1, 0, 0];

yl = get(gca, 'YLim'); % ylimit of the axis
y_points = [yl(1), yl(2), yl(2), yl(1)];
for i = 1 : size(wt, 1) % for each la nina interval
    wt_points = [wt(i, 1), wt(i, 1), wt(i, 2), wt(i, 2)];
    fill(wt_points, y_points, wt_color, 'FaceAlpha', 0.1, 'HandleVisibility','off');
end
for i = 1 : size(dr, 1) % for each el nino interval
    dr_points = [dr(i, 1), dr(i, 1), dr(i, 2), dr(i, 2)];
    fill(dr_points, y_points, dr_color, 'FaceAlpha', 0.1, 'HandleVisibility','off');
end
end