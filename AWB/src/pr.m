function correctedImg = pr(img)
% pr.m    correct wb with perfect reflector
%   Input:
%       img             org image
%   Output:
%       correctedImg    the corrected image
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-30
% Note: 
[height, width, ch] = size(img);
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

rMax = double(max(max(r)));
gMax = double(max(max(g)));
bMax = double(max(max(b)));

rGain = gMax / rMax;
bGain = gMax / bMax;

correctedImg = zeros(height, width, ch);
correctedImg(:,:,1) = r * rGain;
correctedImg(:,:,2) = g;
correctedImg(:,:,3) = b * bGain;
% make sure there is no overflow
correctedImg(correctedImg>255) = 255;
correctedImg = uint8(correctedImg);

end