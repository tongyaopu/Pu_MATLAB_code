load CTDs_observation.mat CTDs
load CTDs_datestr.mat obs_datestr

CTD_fields = fieldnames(CTDs);
CTD_fieldValue = struct2cell(CTDs);

figure
for i = 1 : length(CTD_fields)
    data =  CTDs.(CTD_fields{i}); % data of the selected year, n x 3 array
    CTD_depth = -data(:,1);
    CTD_temp = data(:,2);
    
    plot(CTD_temp, CTD_depth, 'LineWidth', 4); %axis ij
    hold on
end
legend(obs_datestr, 'Location', 'southeast')