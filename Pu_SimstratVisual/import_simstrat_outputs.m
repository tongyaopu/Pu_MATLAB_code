function [arrayTable, arrayMatrix, colName, rowName] = import_simstrat_outputs(fileName)
% This function imports colName and rowName, which is useful to get the
% depth from Simstrat simulation

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end