function deleteFolderContent(folderName)
% delete everything under folder with 'folderName' directly under the current directory
% folderName - str

theFiles = dir(folderName);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(folderName, baseFileName);
    fprintf(1, 'Now deleting %s\n', fullFileName);
    delete(fullFileName);
end
end