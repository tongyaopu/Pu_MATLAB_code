function [] = indicatorEV(EV_dir)

%  simstrat_indicator(EV_dir, dir_ID) go through folders identified with
%  'identifier' under 'EV_dir' directory, read simulation output files, and
%  extract indicators information (defined in methodology part of my
%  thesis), and save it to and EV_dir/Indicators directory. 
%  The saved mat file can be used in the Monte Carlo Analysis
%
% Inputs:
%   EV_dir: directory to Monte Carlo simslations. This directory should
%   contain subfolders of each run. This directory contains multiple
%   folders but only folders identified with identifier will be accessed
%
%   identifier: a char/str that identifies the folders that contain
%   simulation information of each runs. This is to separate out other
%   directory that is not used as Simstrat simulation. E.g, identifier =
%   'TowutiOutput' will read folders which has name 'TowutiOutput' at the
%   front.
%
%

% change directory to the Simstrat Output folder defined by 'EV_dir' -----
fprintf('Folder: %s \n', EV_dir); mustBeFolder(EV_dir)
cd(EV_dir)

% name from EV directory ---------------------------------------------
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
EVName = char(currentWD_split(end));

MTD = []; WTD = []; NMaxG = []; NavgG = [];
listing = dir('TowutiOutput_*');

for i = 1: length(listing)
    runFolder = listing(i);
    runFolderName = runFolder.name;
    
%     cd(runFolderName) % go to each simulation output directory
%     pwd
    
    % Here is where indicators are calculated and stored 
    [temp_strongest_difference, temp_weakest_difference, NN_max_gradient, NN_mean_gradient] = ...
        indicator1(runFolderName);
    MTD = [MTD; temp_weakest_difference];
    WTD = [WTD; temp_weakest_difference];
    NMaxG = [NMaxG; NN_max_gradient];
    NavgG = [NavgG; NN_mean_gradient];
    
    
    cd .. % go back to EV_simulations directory
end
% 
% if ~exist('EV_indicators', 'dir')
%     mkdir('EV_indicators')
% end

cd ../EV_analysis
save(sprintf('MTD_%s.mat', EVName), 'MTD')
save(sprintf('WTD_%s.mat', EVName), 'WTD')
save(sprintf('NMaxG_%s.mat', EVName), 'NMaxG')
save(sprintf('NAvgG_%s.mat', EVName), 'NavgG')
