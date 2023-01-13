%% functions ------------------------------------------------
function [arrayTable, arrayMatrix, colName, rowName] = importDat(fileName)

arrayTable = readtable(fileName);
arrayMatrix = table2array(arrayTable(2:end,2:end));
colName = table2array(arrayTable(1,2:end));
rowName = table2array(arrayTable(2:end,1));

end