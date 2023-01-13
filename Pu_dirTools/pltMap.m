% geoplt
latSeattle = 47.62;
lonSeattle = -122.33;

latAnchorage = 61.20;
lonAnchorage = -149.9;

latPtBarrow = 71.38;
lonPtBarrow = -156.47;

geoplot([latSeattle latAnchorage],[lonSeattle lonAnchorage],'y-',...
    [latSeattle latPtBarrow],[lonSeattle lonPtBarrow],'b:')
geolimits([44 73],[-149 -123])