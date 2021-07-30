function correctedImg = qcgp(img)
% qcgp.m    correct wb with QCGP
%   Input:
%       img             org image
%   Output:
%       correctedImg    the corrected image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-30
% Note: 
I = double(img);
[height, width, ch] = size(img);
r = I(:,:,1);
g = I(:,:,2);
b = I(:,:,3);

% get the mean and max of three channels
rMean = double(mean(mean(r)));
gMean = double(mean(mean(g)));
bMean = double(mean(mean(b)));

rMax = double(max(max(r)));
gMax = double(max(max(g)));
bMax = double(max(max(b)));

kMean = mean([rMean, gMean, bMean]);
kMax = mean([rMax, gMax, bMax]);

correctedImg = zeros(height, width, ch);

% calculate the coefficient
a = [rMean.*rMean, rMean; rMax.*rMax, rMax];
p = a \ [kMean; kMax];
correctedImg(:,:,1) = p(1) * (r.*r) + p(2) * r;

a = [gMean.*gMean, gMean; gMax.*gMax, gMax];
p = a \ [kMean; kMax];
correctedImg(:,:,2) = p(1) * (g.*g) + p(2) * g;


a = [bMean.*bMean, bMean; bMax.*bMax, bMax];
p = a \ [kMean; kMax];
correctedImg(:,:,3) = p(1) * (b.*b) + p(2) * b;

% make sure there is no overflow
correctedImg(correctedImg>255) = 255;
correctedImg = uint8(correctedImg);
end