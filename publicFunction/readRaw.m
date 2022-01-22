function rawData = readRaw(fileName, bitsNum, width, height)
% readRaw.m    get rawData from HiRawImage
%   Input:
%       fileName    the path of HiRawImage 
%       bitsNum      the number of bits of raw image
%       row         the row of the raw image
%       col         the column of the raw image
%   Output:
%       rawData     the matrix of raw image data
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-06-29
% Note: 

% get fileID
fin = fopen(fileName, 'r');
% format precision
switch bitsNum
    case 8
        disp('bits: 8');
        format = sprintf('uint8=>uint8');
    case 10
        disp('bits: 10');
        format = sprintf('uint16=>uint16');
    case 12
        disp('bits: 12');
        format = sprintf('uint16=>uint16');
    case 16
        disp('bits: 16');
        format = sprintf('uint16=>uint16');
end
I = fread(fin, width*height, format);
% plot(I, '.');
z = reshape(I, width, height);
z = z';
rawData = z;
% imshow(z);
end