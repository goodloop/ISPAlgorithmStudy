clc;clear;close all;
path  = 'images\test.jpg';
img = imread(path);
figure();
imshow(img);
title('org');

% corrected by gw
gwImg = gw(img);
figure();
imshow(gwImg);
title('gw');

% corrected by pr
gwImg = pr(img);
figure();
imshow(gwImg);
title('pr');


