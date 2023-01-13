
function [betterfit, residual, residual_std] = runtestfit3_tongyao_function(xdatainput, ydatainput, sigmainput, ...
    sp, ft_string, fName)

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

%% create outputs folder if it didn't exist
 if ~exist('outputs/', 'dir')
       mkdir('outputs');
 end

fn = sprintf('outputs/log_%s.txt', fName);
if ~isfile(fn)
    fID = fopen(fn, 'w');
else
    fID = fopen(fn, 'a+');
end

fprintf(fID, 'Current Time: %s \n', datestr(now,'HH:MM:SS.FFF'));

%% simple polynomial fitting
% simple polynomial fitting with no weights.
% gives the right central value if the error bars are the same size.
% but how often does that happen ?  never in physics.

if strcmp(fName, 'basic')
    simplefit = polyfit(xdatainput,ydatainput,1);
    
    figure
    subplot(2, 1, 1)
    myErrorbarplot = errorbar(xdatainput,ydatainput,sigmainput,'LineStyle','none', ...
        'LineWidth', 3.0, 'Marker', 'o' );
    % make some of the pot minimally handsome
    set(myErrorbarplot, 'LineStyle' , 'none', 'Color', [0. 0. 0.], ...
        'MarkerSize',6, 'MarkerFaceColor', [0. 0. 0.]);
    set(gcf,'color','white');
    set(gca, 'Box', 'off', 'LineWidth',3, 'FontSize', 18);
    
    hold on
    
    % Literally make a line to plot, then plot it.
    xmodel = (0:0.1:11.)';
    % need to replace simplefit with my own values
    slope = simplefit(1);
    intercept = simplefit(2);
    % uncomment these to use the best fit slope and intercept
    % obtained by any number of methods.
    %slope = 1.42725
    %intercept = 0.17514
    
    ymodel = polyval([slope,intercept],xmodel);
    mySimpleLine = plot(xmodel,ymodel,'-');
    hold off
    
    % Make things even prettier.
    myXLabel = xlabel('time (seconds)','FontSize',18);
    myYLabel = ylabel('distance (meters)','FontSize',18);
%     myTitle = title('illustration of two fits','FontSize',18);
    myTitle = title('simple best fit','FontSize',18);
    set(mySimpleLine, 'LineWidth', 3.0, 'Color', [0. 0. 1.]);
    legend('off')
    
    % compute the chisquare by hand and make a table
    fitline = polyval([slope,intercept],xdatainput);
    
    residual = fitline - ydatainput;
    fracresidual = residual ./ sigmainput;
    chisquareterm = fracresidual .^ 2;
    chi2 = dot(fracresidual,fracresidual);
    dof = length(xdatainput) - length(sp);
    chiv = chi2./dof;
    
    % actually look at them, are the big ones the size you think they should be
    % ?
    
    subplot(2, 1, 2)
    myErrorbarplot = errorbar(xdatainput,residual,sigmainput,'LineStyle','none', ...
        'LineWidth', 3.0, 'Marker', 'o' );
    hold on
    yline(0, '--b')
    % make some of the pot minimally handsome
    set(myErrorbarplot, 'LineStyle' , 'none', 'Color', [0. 0. 0.], ...
        'MarkerSize',6, 'MarkerFaceColor', [0. 0. 0.]);
    set(gcf,'color','white');
    set(gca, 'Box', 'off', 'LineWidth',3, 'FontSize', 18);
    % Make things even prettier.
    myXLabel = xlabel('time (seconds)','FontSize',18);
    myYLabel = ylabel('data - model (meters)','FontSize',18);
    myTitle = title('illustration of residual','FontSize',18);
    legend('off')
    
    saveas(gcf, sprintf('outputs/fig1_SimpleFit_%s.png', fName))
    % return
    % what does this return do?
end

if strcmp(fName, 'basic')
    fprintf(fID, '------- Simple Linear Fit ------ \n');
    fprintf(fID, 'slope = %.4f, intercept = %.4f; \n', slope, intercept);
    fprintf(fID, 'chi2 = %.4f; \n', chi2);
end

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

% Print this out so we can write it in our paper
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

residual = betterfit(xdatainput) - ydatainput;
residual_std = std(residual);

fprintf(fID, 'residual_std = %.3f\n', residual_std);
fprintf(fID, '******The End******\n\n\n');
fclose(fID);

