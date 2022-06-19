xyz_primaries = rgb2xyz([1 0 0; 0 1 0; 0 0 1]);
xyzMag = sum(xyz_primaries,2);
x_primary = xyz_primaries(:,1)./xyzMag;
y_primary = xyz_primaries(:,2)./xyzMag;
wp = whitepoint('D65');
wpMag = sum(wp,2);
x_whitepoint = wp(:,1)./wpMag;
y_whitepoint = wp(:,2)./wpMag;
plotChromaticity