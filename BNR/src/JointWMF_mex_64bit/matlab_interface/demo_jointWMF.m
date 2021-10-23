
close all;

I = imread('imgs/image1.png');

tic;
res = jointWMF(I,I,10,25.5,256,256,1,'exp');
toc;

figure, imshow(res);