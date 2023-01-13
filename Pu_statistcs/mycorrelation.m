function corr = mycorrelation(A,B)

% compute the correlation of sets A and B by hand
% assumes you are not passing any bogus values
% there are canned routines to do this, 
% in matlab called cov
% our version will also return Pearsons R value

% you need to take out some basic trends
% the mean of A and B are not the same
% calculate the mean

meanA = mean(A);
meanB = mean(B);

residualA = A - meanA; % add code
residualB = B - meanB; % add code

% you may also have a "secular" trend,
% could be linear or rise and fall with the year
% and you could write code to take that out
% a simple linear function or one motivated by physics

% Lets not *do* that today.  But see later when it comes up.   
% Instead, pick short time scales.

% the covariance definition is on the board.
% the properties term by term and the sum are important
% sketch on paper what makes the sum small or large
% then implement it in one line

N = length(A);
if length(A) ~= length(B)
    error('input must be the same length')
end
mycovariance = sum(residualA .* residualB); % add code

% make the average by dividing by number of elements.

mycovariance = mycovariance / length(residualA); %(size(residualA,1));

% what a lot of people use is Pearsons R test
% which is defined covariance(A,B)/std(A)std(B)
% implement this.

corr.R = mycovariance / (std(A)*std(B));% add code

% there is a slight oddity here.  
% When the rest is working, correct for it.

% you wont be surprised that we can perform
% a P-value for the Null hypothesis (which is what? - only natural flucturation )
% even if we are not interested in that hypothesis.
% The statistic that relates R to a pdf is Gaussian,
% it is Students T distribution.
% the specific form to get Students T from Pearsons R is 

dof = size(residualA,1) - 2;
corr.T = corr.R * sqrt( dof / (1.0 - corr.R * corr.R) );

% then the P-value comes from the cdf for the T distribution
corr.nullP = 1.0 - tcdf(corr.T, dof - 2);

% might be tricky to print this out.
