function [r, lag] = xcorr_TY(series1, series2, laglim)

if length(series1) ~= length(series2)
    error('correlation nput must have the same length')
end

lag = -[1 : laglim]; % this matches xcorr definition of lag by matlab
r = zeros(length(lag), 2); % change 2 to 1 after comfirming output
for i = -lag
    series2_cropped = series2(i:end); 
    series1_cropped = series1(1:length(series2_cropped));

    % calculate pearson's r
    ri = corrcoef(series2_cropped, series1_cropped, 'Rows','pairwise');
    ri = ri(2, 1);
    r(i, 1) = ri;

    corrR = mycorrelation(series2_cropped, series1_cropped); % data analysis function
    ri = corrR.R;
    r(i, 2) = ri;

end