clc;clear;close all;
img = imread('images/distortion.png');
grayImg = rgb2gray(img);
[h, w, c] = size(grayImg);

expandImg = padarray(grayImg,[1 1],'symmetric','both');

%% --------------------------------------------------------------
% orgX = newX
% orgY = -0.47*orgX + 0.43*orgY + 5.3*10^(-4)*newX*newY + 505
newImg = zeros(h, w, c);
for x = 1: h
    for y = 1: w
        orgX = x;
        orgY = -0.47*x + 0.43*y + 5.3*10^(-4)*x*y + 505;
        if orgY < 1
            orgY = 1;
        else
            if orgY > 1920
              orgY = 1920;
            end
        end
        up = ceil(orgY);
        down = floor(orgY);
        newImg(x, y) = grayImg(orgX, down) * (up - orgY) + grayImg(orgX, down) * (orgY -down);
    end
end

figure()
subplot(121)
imshow(grayImg)
title('org')

subplot(122)
imshow(uint8(newImg))
title('correction')



