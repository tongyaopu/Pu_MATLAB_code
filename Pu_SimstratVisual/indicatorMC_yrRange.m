function [] = indicatorMC_yrRange(MC_dir, yrRange)

%  simstrat_indicator(MC_dir, dir_ID) go through folders identified with
%  'identifier' under 'MC_dir' directory, read simulation output files, and
%  extract indicators information (defined in methodology part of my
%  thesis), and save it to and MC_dir/Indicators directory. 
%  The saved mat file can be used in the Monte Carlo Analysis
%
% Inputs:
%   MC_dir: directory to Monte Carlo simslations. This directory should
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

% change directory to the Simstrat Output folder defined by 'MC_dir' -----
fprintf('Folder: %s \n', MC_dir); mustBeFolder(MC_dir)
cd(MC_dir)

% name from MC directory ---------------------------------------------
currentWD = pwd; 
currentWD_split = strsplit(currentWD, '\'); % '/' in mac, '\' in windows
MCName = char(currentWD_split(end));

MTD = []; WTD = []; NMaxG = []; NavgG = [];
listing = dir('TowutiOutput_*');

for i = 1: length(listing)
    runFolder = listing(i);
    runFolderName = runFolder.name;
    
%     cd(runFolderName) % go to each simulation output directory
%     pwd
%     try
    % Here is where indicators are calculated and stored 
    [temp_strongest_difference, temp_weakest_difference, NN_max_gradient, NN_mean_gradient] = ...
        indicator1_yrRange(runFolderName, yrRange);
    MTD = [MTD; temp_strongest_difference];
    WTD = [WTD; temp_weakest_difference];
    NMaxG = [NMaxG; NN_max_gradient];
    NavgG = [NavgG; NN_mean_gradient];
    
%     end
    cd .. % go back to MC_simulations directory
end
% 
% if ~exist('MC_indicators', 'dir')
%     mkdir('MC_indicators')
% end

cd ../MC_analysis
save(sprintf('MTD_%s_%d_%d.mat', MCName, yrRange(1), yrRange(2)), 'MTD')
save(sprintf('WTD_%s_%d_%d.mat', MCName, yrRange(1), yrRange(2)), 'WTD')
save(sprintf('NMaxG_%s_%d_%d.mat', MCName, yrRange(1), yrRange(2)), 'NMaxG')
save(sprintf('NAvgG_%s_%d_%d.mat', MCName, yrRange(1), yrRange(2)), 'NavgG')
