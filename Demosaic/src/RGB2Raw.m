function rawData = RGB2Raw(path, BayerFormat)
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
rawImg = zeros(height, width);

switch BayerFormat
    case 'RGGB'
        % R
        rawImg(1:2:end, 1:2:end) = orgImg(1:2:end, 1:2:end, 1);
        % B
        rawImg(2:2:end, 2:2:end) = orgImg(2:2:end, 2:2:end, 3);
        % G
        rawImg(2:2:end, 1:2:end) = orgImg(2:2:end, 1:2:end, 2);
        rawImg(1:2:end, 2:2:end) = orgImg(1:2:end, 2:2:end, 2);
    case 'GRBG'
        % R
        rawImg(1:2:end, 2:2:end) = orgImg(1:2:end, 2:2:end, 1);
        % B
        rawImg(2:2:end, 1:2:end) = orgImg(2:2:end, 1:2:end, 3);
        % G
        rawImg(1:2:end, 1:2:end) = orgImg(1:2:end, 1:2:end, 2);
        rawImg(2:2:end, 2:2:end) = orgImg(2:2:end, 2:2:end, 2);
    case 'GBRG'
        % R
        rawImg(2:2:end, 1:2:end) = orgImg(2:2:end, 1:2:end, 1);
        % B
        rawImg(1:2:end, 2:2:end) = orgImg(1:2:end, 2:2:end, 3);
        % G
        rawImg(1:2:end, 1:2:end) = orgImg(1:2:end, 1:2:end, 2);
        rawImg(2:2:end, 2:2:end) = orgImg(2:2:end, 2:2:end, 2);
end
rawData = rawImg;
% save rawData
nameList = strsplit(path, '.');
fileName = char(cellstr(nameList(1)));
disp(fileName);
rawName = sprintf('%s_8bits_%s.raw', fileName, BayerFormat);
fb = fopen(rawName, 'wb');
rawImg = rawImg';
rawList = rawImg(:);
fwrite(fb, rawList, 'uint8');
fclose(fb);
end