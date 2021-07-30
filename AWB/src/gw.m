function correctedImg = gw(img)
% gw.m    correct wb with gray world
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

% get the mean of three channels
rMean = double(mean(mean(r)));
gMean = double(mean(mean(g)));
bMean = double(mean(mean(b)));

% get the rGain and bGain based on gMean to make sure that 
% the mean of the three channels are the same value after correcting,;
rGain = gMean / rMean;
bGain = gMean / bMean;

correctedImg = zeros(height, width, ch);
correctedImg(:,:,1) = r * rGain;
correctedImg(:,:,2) = g;
correctedImg(:,:,3) = b * bGain;
% make sure there is no overflow
correctedImg(correctedImg>255) = 255;
correctedImg = uint8(correctedImg);
end