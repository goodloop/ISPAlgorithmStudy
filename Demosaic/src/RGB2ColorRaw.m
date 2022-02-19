function rawData = RGB2ColorRaw(path)
% RGB2Raw.m         get rawData from HiRawImage
%   Input:
%       path    	the path of orgImage
%       BayerFormat the format of raw, eg. 'RGGB','GRBG', 'GBRG'
%   Output:
%       rawData     the matrix of raw image data
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-05
% Note: 
orgImg = imread(path);
[height, width, channel] = size(orgImg);
if channel ~= 3
    fprintf('please input RGB format');
    return;
end
rawImg = zeros(height, width, channel);


% R
rawImg(1:2:end, 1:2:end, 1) = orgImg(1:2:end, 1:2:end, 1);
% B
rawImg(2:2:end, 2:2:end, 3) = orgImg(2:2:end, 2:2:end, 3);
% G
rawImg(2:2:end, 1:2:end, 2) = orgImg(2:2:end, 1:2:end, 2);
rawImg(1:2:end, 2:2:end, 2) = orgImg(1:2:end, 2:2:end, 2);

rawData = rawImg;
imshow(uint8(rawData));
end