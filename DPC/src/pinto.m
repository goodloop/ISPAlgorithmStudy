clc;clear;close all;
tic;
% --------global velue---------
expandNum = 2;
Th = 30;

% --------raw parameters-------
filePath = 'images/HisiRAW_4208x3120_8bits_RGGB.raw';
bayerFormat = 'RGGB';
bayerBits = 8;
row = 4208;
col = 3120;
% -----------------------------

rawData = readRaw(filePath, bayerBits, row, col);
[height, width, channel] = size(rawData);

img_expand = expandRaw(rawData, expandNum);

disImg = zeros(height, width);
for i = expandNum+1 : 2 : height+expandNum
    for j = expandNum+1 : 2 : width+expandNum
        % R
        % get the pixel around the current R pixel
        around_R_pixel = [img_expand(i-2, j-2) img_expand(i-2, j) img_expand(i-2, j+2) img_expand(i, j-2) img_expand(i, j+2) img_expand(i+2, j-2) img_expand(i+2, j) img_expand(i+2, j+2)];
        disImg(i-expandNum, j-expandNum) = judgeDefectPixel(around_R_pixel, img_expand(i, j), Th);
        % Gr
        % get the pixel around the current Gr pixel
        around_Gr_pixel = [img_expand(i-1, j) img_expand(i-2, j+1) img_expand(i-1, j+2)  img_expand(i, j-1) img_expand(i, j+3) img_expand(i+1, j) img_expand(i+2, j+1) img_expand(i+1, j+2)];
        disImg(i-expandNum, j-expandNum+1) = judgeDefectPixel(around_Gr_pixel, img_expand(i, j+1), Th);
        % B
        % get the pixel around the current B pixel
        around_B_pixel = [img_expand(i-1, j-1) img_expand(i-1, j+1) img_expand(i-1, j+3) img_expand(i+1, j-1) img_expand(i+1, j+3) img_expand(i+3, j-1) img_expand(i+3, j+1) img_expand(i+3, j+3)];
        disImg(i-expandNum+1, j-expandNum+1) = judgeDefectPixel(around_B_pixel, img_expand(i+1, j+1), Th);
        % Gb
        % get the pixel around the current Gb pixel
        around_Gb_pixel = [img_expand(i, j-1) img_expand(i-1, j) img_expand(i, j+1) img_expand(i+1, j-2) img_expand(i+1, j+2) img_expand(i+2, j-1) img_expand(i+3, j) img_expand(i+2, j+1)];
        disImg(i-expandNum+1, j-expandNum) = judgeDefectPixel(around_Gb_pixel, img_expand(i+1, j), Th);
    end
end
figure();
imshow(rawData);title('org');
figure();
imshow(uint8(disImg));title('corrected');
disp(['cost time£º',num2str(toc)])