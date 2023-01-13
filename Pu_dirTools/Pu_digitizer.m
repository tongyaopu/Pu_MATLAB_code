%% Exercise 19 - Working with images
% edited from sergei's code
%% 1. Digitization from screen
% One of the common tasks in working with data is digitization of data from
% images. Here is an example of doing this task in Matlab. Digitize the
% temperature profile as a function of depth in Lake Kivu (East Africa).
% First, download the image KivuT.jpg and load it into workspace. Replace
% the image path below by the directory to which you downloaded the image.
% I=imread('img.png');
dir_file = '/Users/tongyaop/Documents/Lake_Towuti/References_TowutiProfiles/';
fn = 'LakeTowutiLakeLevel';
I=imread([dir_file,fn,'.png']);

figure('Name','initial', 'Position',[0 0 1000 1000])
imshow(I, 'InitialMagnification', 'fit')
% The command 'imread' reads the .jpg format and parses it into a 3D array
% where the first two dimensions are width and height, and the third one is
% the color depth.
%%
% Now you need to relate the pixel coordinates to the data coordinates. You
% can use the 'ginput' command to get the pixel coordinates of the corner
% with the minimum x- and y- values (upper left in this example) and the corner
% with the maximum values (lower right here).
a=size(I,2); b=size(I,1);
disp('Click on the corner of the graph with (xmin,ymin) then (xmax, ymax), then <return>')
[xcr ycr]=ginput;
%%
% Define the limits for the axes in the image. These are the data
% coordinates of the points that you just clicked on.
% xmin=0;xmax=1.0;
% ymin=0; ymax=30;
xmin=731490;xmax=734412;
ymin=-2; ymax=2;
%%
% Now you can digitize the data. Click on the data points that you would
% like to read the coordinates from. The data values will be in pixel
% coordinates.
[xdata ydata]=ginput;
% Convert the points to the real coordinates and verify the graph.
XDATA = xmin + (xmax-xmin)/(xcr(2)-xcr(1))*(xdata-xcr(1));
YDATA = ymin + (ymax-ymin)/(ycr(2)-ycr(1))*(ydata-ycr(1));

figure
plot(XDATA,YDATA,'o-');axis ij
axis([xmin xmax ymin ymax])

save([dir_file, fn], 'XDATA','YDATA')
saveas(gcf, [dir_file, fn,'_digi.png'])