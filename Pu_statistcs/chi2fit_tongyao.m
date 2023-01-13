
function [betterfit, FitParameters, FitErrors, residual, fitchi2, fitdof, pval] = chi2fit_tongyao(xdatainput, ydatainput, sigmainput, ...
    sp, ft_string, fName, logFlag, figureFlag)

% How to use this function:
% 1. load data from :
%   [xdatainput,ydatainput,sigmainput] = textread('../mytestfile.dat','%f %f %f');
% 2. change sp, starting point:
%   sp = [1 1 1]; % quadratic
%   sp = [1 1]; % linear
%   sp = [1]; % constant
% 3. Change ft_string, fitting function:
%   ft_string = 'a*x^2 + b*x + c'; % fittype string
%   ft_string = 'a*x + b'; % fittype string
%   ft_string = '0*x + b'; % fittype string for constant fitting
% 4. change fName, file name, if needed:


%% curve fitting nonlinear least squares
% what we really want requires the curve fitting toolbox
% which sometimes costs extra money or has license restrictions
% octave might have a variant that is free and suitable.
% but it is not identical enough to fit in the same script.

myoptions = fitoptions('Method', 'NonlinearLeastSquares','StartPoint',sp);
% matlab wants the weights = 1/errorbar^2, so large error = small weight.
% some other fit tools want sigma for the points directly.
myoptions.weights = sigmainput.^(-2);
ft = fittype(ft_string, 'options', myoptions);
[betterfit, gof, output] = fit(xdatainput,ydatainput,ft);

% betterfit contains the parameters we want, this method gets them.
FitParameters = coeffvalues(betterfit);

% but it gives confidence bounds at 95%, not one-sigma.
% thats good for some things, but is not usually what physics-types want
% and the following syntax doesn't give the right thing either.
% confint(betterfit,0.6827)
% see later how to actually get it.  Not sure why they did this.

% gof is short for goodness of fit, it calculated both
% chisquare and degrees of freedom for you, so you don't have to.
% but of course, you could calculate them by hand, if you needed.
fitchi2 = gof.sse;
fitdof = gof.dfe;
chi2_probability = chi2cdf(fitchi2, fitdof);
pval = chi2cdf(fitchi2, fitdof);
% dof = length(xdatainput) - length(sp);
chiv = fitchi2./fitdof;
% can put this into the chi2pdf to find how likely this would be.

% output is a data structure with a bunch of things in it,
% including residuals and an error matrix in Jacobian format.
% We can transform (sum) the Jacobian into the standard Covariance matrix
% which is what physics-folks usually want to see.

J=output.Jacobian;
FitCovariance=inv(J'*J);
FitErrors=sqrt(diag(FitCovariance));


residual = betterfit(xdatainput) - ydatainput;
residual_std = std(residual);

if logFlag
    % Print this out so we can write it in our paper
    logfn = sprintf('log_%s.txt', fName);
    if ~isfile(logfn)
        fID = fopen(logfn, 'w');
    else
        fID = fopen(logfn, 'a+');
    end

    fprintf(fID, 'Current Time: %s \n', datestr(now,'HH:MM:SS.FFF'));

    fprintf(fID, '------- CurveFitting Toolbox Fit ------ \n');

    if length(sp) == 1
        fprintf(fID, 'single parameter fitting\n');
        fprintf(fID, 'constant %1.7f +/- %1.7f\n', FitParameters(1), FitErrors(1));
    elseif length(sp) == 2 % if have second parameter
        fprintf(fID, 'linear fitting\n');
        fprintf(fID, 'slope %1.7f +/- %1.7f\n', FitParameters(1), FitErrors(1));
        fprintf(fID, 'intercept %1.7f +/- %1.7f\n', FitParameters(2), FitErrors(2));
    elseif length(sp) == 3 % if have second parameter
        fprintf(fID, 'quadratic fitting\n');
        fprintf(fID, 'a %1.7f +/- %1.7f\n', FitParameters(1), FitErrors(1));
        fprintf(fID, 'b %1.7f +/- %1.7f\n', FitParameters(2), FitErrors(2));
        fprintf(fID, 'c %1.7f +/- %1.7f\n', FitParameters(3), FitErrors(3));
    elseif length(sp) > 3 % multiple polynomials
        fprintf(fID, 'multipolynomial fitting\n');
        for j = 1 :length(sp)
            fprintf(fID, '%s %1.7f +/- %1.7f\n', 96 + j, FitParameters(j), FitErrors(j));
        end
    end

    fprintf(fID, 'chi^2 %.3f \n', fitchi2);
    fprintf(fID, 'probability of this chi^2 in dof = %d cdf is %.3f\n', fitdof, chi2_probability);
    fprintf(fID, 'chi2/dof = %.3f\n', chiv);


    fprintf(fID, 'residual_std = %.3f\n', residual_std);
    fprintf(fID, '******The End******\n\n\n');
end

if figureFlag
    figure
    subplot(2, 1, 1)
    errorbar(xdatainput, ydatainput, sigmainput, 'o', 'LineWidth', 3)
    hold on
    plot(xdatainput, betterfit(xdatainput), 'r', 'LineWidth', 3)
    xlabel('xdatainput'); ylabel('ydatainput')
    title('primative chi2 fitting figure')

    subplot(2, 1, 2)
    errorbar(xdatainput, residual, sigmainput, 'o', 'LineWidth', 3)
    hold on
    yline(0, '--r', 'LineWidth',3)
    xlabel('xdatainput'); ylabel('residual')

    figfn = sprintf('chi2fit_plot_primative_%s.png', fName);
    saveas(gcf, figfn)
end

