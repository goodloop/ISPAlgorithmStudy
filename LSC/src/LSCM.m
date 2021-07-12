%% --------------------------------
%% author:wtzhu
%% date: 20210705
%% fuction: main file of LSM
%% --------------------------------
lscRefImg = double(imread('images/lscRefImg.jpg'));
load('src/data/corTab.mat')
corImg = uint8(lscRefImg .* corTab);
figure;
subplot(121);imshow(uint8(lscRefImg));title('org');
subplot(122);imshow(corImg);title('corrected');