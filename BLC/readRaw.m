function rawData = readRaw(fileName, bitNum, row, col)
% readRaw.m    get rawData from HiRawImage
%   Input:
%       fileName    the path of HiRawImage 
%       bitNum      the number of bits of raw image
%       row         the row of the raw image
%       col         the column of the raw image
%   Output:
%       rawData     the matrix of raw image data
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-06-29
% Note: this func can read 8bits or 16bits only, 10bit and 12bits will be
% updated after some time

% get fileID
fin = fopen(fileName, 'r');
% format precision
format = sprintf('uint%d=>uint%d',bitNum,bitNum);
I = fread(fin, row*col, format);
z = reshape(I, row, col);
z = z';
rawData = imshow(z);
end