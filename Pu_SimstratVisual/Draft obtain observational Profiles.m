obs_datestr = datestr(['1997-09-18'; '2000-09-25'; '2002-02-06'; '2004-08-26'; '2006-05-29'; '2009-06-16'])

for k = 1 : length(dinfo)
    colororder(colors_p)
%    resolve the time that the CTD is measured
    thisfilename = dinfo(k).name;  %just the name
    C = strsplit(thisfilename, '_'); % split the string
    dastr = strsplit(string(C(6)), '.');
    yr = str2double(C(4)); mo = str2double(C(5)); da = str2double(dastr(1)); % extract time info from the data
    t_vector = [yr mo da]; t_datetime = datetime(t_vector);
    str_date = [str_date; string(t_datetime)];
    
%    read and save the file in a struct named CTDs
    arrayname = sprintf('CTD_%d', yr);
    CTDs.(arrayname) = readmatrix(thisfilename);
    
    CTD_depth = - CTDs.(arrayname)(:,1); temperature = CTDs.(arrayname)(:,2);
    
