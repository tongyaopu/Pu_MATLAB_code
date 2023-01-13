function [A_out, B_out] = rm_NaN(A, B)
% remove NaN value at the same entry between matrix A and B

if size(A) ~= size(B)
    error('matrix A and matrix B should be the same size')
end

% if sum(isnan(A) + isnan(B), 'all') >= 1
%     disp('there is NaN values. removing in process ...')
% end

NaNidx = find(isnan(B));
A(NaNidx) = []; B(NaNidx) = [];
NaNidx = find(isnan(A));
A(NaNidx) = []; B(NaNidx) = [];

A_out = A; B_out = B;