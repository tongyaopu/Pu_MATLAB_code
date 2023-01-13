function [] = visual_fluxCompare(whichFlux, dir1, dir2, FileName)

% simstratVisual_fluxCompare(whichFlux, dir1, dir2, FileName) read and
% compare timeseries (defined by 'whichFlux') between run1 output located
% in dir1 and run2 output located in dir2, and save the output matrix and
% figure based on 'whichFlux' and 'Filename'
%
% Inputs: 
%   - whichFlux: str , 'HA', 'HW', 'HV', 'HK', 'Rad0' or other timeseries
%   outputed from Simstrat
%   - dir1: directory of output file from simulation #1. It shoud contain
%   XX_out.dat for reading
%   - dir2: same as dir1, but for simulation #2
%   - Filename: str. No need to specify which flux choosen and file
%   extension since they are included in the code. a common one can be '00XVS00Y'
%
% Outputs:
%   saved figure and array under 'C:\Users\tongy\Simstrat\TowutiProjects\quickComparPlots'


cd(dir1)
fn1 = sprintf([whichFlux, '_out.dat']);
flux_out1 = readmatrix(fn1);
t_days1 = flux_out1(:, 1); 
t_datetime1 = datetime(t_days1 + datenum(1900,01,01), 'ConvertFrom', 'datenum');
flux1 = flux_out1(:, 2);

cd(dir2)
fn2 = sprintf([whichFlux, '_out.dat']);
flux_out2 = readmatrix(fn2);
t_days2 = flux_out2(:, 1); 
t_datetime2 = datetime(t_days2 + datenum(1900,01,01), 'ConvertFrom', 'datenum');
flux2 = flux_out2(:, 2);

figure
plot(t_datetime1, flux1);
hold on
plot(t_datetime2, flux2);

switch whichFlux % create label etc based on whichFlux
    case 'HA'
        ylabel('LW radiation from air [W/m2]')
    case 'HW'
        ylabel('LW radiation from water [W/m2]')
    case 'HK'
        ylabel('Sensible Heat [W/m2]')
    case 'HA'
        ylabel('Latent Heat [W/m2]')
end

cd 'C:\Users\tongy\Simstrat\TowutiProjects\quickComparPlots'
saveas(gcf, sprintf('%s_%s.png', whichFlux, FileName))
save(sprintf('%s_%s.mat', whichFlux, FileName), 't_datetime1', 'flux1', 't_datetime2', 'flux2')
end