function [X] = myinterpolate_matlab(t, X)
nanx = isnan(X);
X(nanx) = interp1(t(~nanx), X(~nanx), t(nanx));
end