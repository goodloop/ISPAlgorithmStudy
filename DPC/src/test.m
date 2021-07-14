clc;clear;close all;

% --------global velue---------
expandNum = 1;
Th = 50;
% -----------------------------

img = imread('images/DPC_off.jpg');
[height, width, channel] = size(img);
img_r = img(:,:,1);
img_g = img(:,:,2);
img_b = img(:,:,3);

img_r_expand = mirrorExpand(img_r, expandNum);
% r = padarray(img_r, [3 3], 'symmetric', 'both');
% img_g_expand = mirrorExpand(img_g, expandNum);
% img_b_expand = mirrorExpand(img_b, expandNum);

disImg = zeros(height, width);
for i = expandNum+1 : height+expandNum
    for j = expandNum+1 : width+expandNum
        kernal_img = img_r_expand(i-expandNum:i+expandNum, j-expandNum:j+expandNum);
        kernal_img_sort = sort(kernal_img);
        kernal_img_median = kernal_img_sort(uint8((2*expandNum+1)^2/2)+1);
        
        diff = kernal_img - ones(2*expandNum+1)*img_r_expand(i, j);
        if (nnz(diff<0) > (2*expandNum+1)^2)-2 || (nnz(diff>0) > (2*expandNum+1)^2-2)
            disImg(i-expandNum, j-expandNum) = kernal_img_median;
        else
            disImg(i-expandNum, j-expandNum) = img_r_expand(i, j);
        end
    end
end
figure();
subplot(121);imshow(img_r);title('org');
subplot(122);imshow(uint8(disImg));title('corrected');
