clc;clear;close all;
path  = 'images\NikonD5200_0001_G_AS.png'; %test.jpg NikonD5200_0001_G_AS.png
img = imread(path);
figure();
subplot(221)
imshow(img);
title('org');

% corrected by gw
gwImg = gw(img);
subplot(222)
imshow(gwImg);
title('gw');

% corrected by pr
gwImg = pr(img);
subplot(223)
imshow(gwImg);
title('pr');

% corrected by qcgp
gwImg = qcgp(img);
subplot(224)
imshow(gwImg);
title('qcgp');


