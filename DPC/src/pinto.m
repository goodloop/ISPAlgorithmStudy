clc;clear;close all;

% --------global velue---------
expandNum = 2;
Th = 50;


filePath = 'images/HisiRAW_4208x3120_8bits_RGGB.raw';
bayerFormat = 'RGGB';
bayerBits = 8;
row = 4208;
col = 3120;
% -----------------------------

rawData = readRaw(filePath, bayerBits, row, col);
[height, width, channel] = size(rawData);
imshow(rawData);

img_r_expand = mirrorExpand(img_r, expandNum);

disImg = zeros(height, width);
for i = expandNum+1 : height+expandNum
    for j = expandNum+1 : width+expandNum
        kernal_img = img_r_expand(i-expandNum:i+expandNum, j-expandNum:j+expandNum);
        kernal_img_list = kernal_img(:)';
        around_value = kernal_img_list([1: floor(numel(kernal_img_list)/2), floor(numel(kernal_img_list)/2)+2:end]);
        around_value_sort = sort(around_value);
        around_count = numel(around_value_sort);
        kernal_img_median = (around_value_sort(around_count/2) + around_value_sort(around_count/2+1))/2;
        
        diff = around_value_sort - ones(1, around_count) * img_r_expand(i, j);
        if (nnz(diff<0) >= (around_count-1)) || (nnz(diff>0) >= (around_count-1))
            disImg(i-expandNum, j-expandNum) = kernal_img_median;
        else
            disImg(i-expandNum, j-expandNum) = img_r_expand(i, j);
        end
    end
end
figure();
subplot(121);imshow(uint8(img_r));title('org');
subplot(122);imshow(uint8(disImg));title('corrected');
