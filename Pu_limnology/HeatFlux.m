function [ShortwaveIn, LongwaveOut, LongwaveIn, Sensible, Latent, Net] = HeatFlux(dsw, Ta, Ts, rh, ur)
% modified from lim calss
% Compute heat fluxes:
% - Outgoing Longwave radiation as blackbody
% - Net Shortwave radiation from measured incoming Shortwave
% - Downward Longwave (based on Fairall et al. JCLIM 2008)
% - Sensible (uses hfbulktc.m)
% - Latent   (uses hfbulktc.m)

% -------- PARAMETERS --------------
% dsw = 200; %900/sqrt(2); % measured solar insolation (W/m2)  <--- SPECIFY MEASURED VALUE
% %Ta = 0:30;
% %Ta=27; % air temperature (C)
% Ts=29; % sea surface temperature (C)
% rh=80; %70-90 % relative humidity (%)
% ur=0.85; %wind speed (m/s) 3 m above the surface

emissivity=0.98; % grey-body coefficient
lat=2;   % latitude
Pa=1010; % air pressure (mbar)
zr=2;zt=2;zq=2;   % height above surface for measurements (m)
%  qa=4; % specific humidity (g/kg = gH2O per kg (~m3) of dry air)

%--------------------------------------
% disp('  ');
% disp('-------------------------------------');
% disp(cat(2,'Ta=',num2str(Ta),' Ts=',num2str(Ts),' rh=',num2str(rh),' windspeed=',num2str(ur)));
% disp('-------Calculated fluxes (W/m2)---------');

% Calculate specific humidity from relative humidity
 qa=1000*(rh/100 * 2.541e6 * exp(-5415.0 / (Ta+273.15)) * 18/29);

% Convert specific humidity to relative humidity
%    press = Pa;
%    qair=qa/1000;
%    es= 6.112 * exp((17.67 * Ta)/(Ta + 243.5));
%    e = qair * press / (0.378 * qair + 0.622);
%    rh = (e / es)*100;
%    rh=min(rh,100);
%    rh=max(0,rh);
%disp (cat(2,'Calculated relative humidity rh= ', num2str(rh),'%')); 

% Net Shortwave
ShortwaveIn=emissivity*dsw;
% disp (cat(2,'Shortwave in (from measured) = ', num2str(ShortwaveIn)));

% Stefan-Boltzmann law:
LongwaveOut = emissivity*5.6704E-8*(Ts+273.16)^4;
% disp (cat(2,'Longwave out = ', num2str(LongwaveOut)));

% Approximation for longwave downward
LongwaveIn=(.52+.13/60*abs(lat)+(.082-.03/60*abs(lat)).*sqrt(qa)).*(5.67e-8*(Ta+273.15).^4);
% disp (cat(2,'Longwave in = (approx) ', num2str(LongwaveIn)));

% Sensible and Latent
w=hfbulktc(ur,zr,Ta,zt,rh,zq,Pa,Ts);
Sensible=w(1); Latent=w(2);    
% disp (cat(2,'Sensible in  = ', num2str(Sensible')));
% disp (cat(2,'Latent in = ', num2str(Latent')));

Net=ShortwaveIn+LongwaveIn-LongwaveOut+Sensible+Latent;
% disp (cat(2,'Net flux (W/m2) = ', num2str(Net)));

end

