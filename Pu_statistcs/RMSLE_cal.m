function RMSLE = RMSLE_cal(A, B)
% calculate RMSLE from two numbers/ matrices
if size(A) ~= size(B)
    error('matrix A and matrix B should be the same size')
end

if sum(isnan(A) + isnan(B), 'all') >= 1
    error('there is NaN value in your matrix, get rid of that before preceeding')
end

N = numel(A);
logA = log10(A + 1);
logB = log10(B + 1);
logDiff = logA - logB;
logDiffSq = logDiff.^2;
sumlogDiffSq = sum(logDiffSq, 'all');
RMSLE = sqrt(sumlogDiffSq / N);
end