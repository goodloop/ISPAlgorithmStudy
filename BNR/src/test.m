%% ²âÊÔº¯Êý
clc,clear all,close all;
ima=double(imread('./images/lena.bmp'));
[wid,len,channels]=size(ima);
% add  noise
sigma=10;
rima=ima+sigma*randn(size(ima)); 

% denoise
fima=rima;
if channels>2
    for i = 1:channels      
       fima(:,:,i) = NLmeansfilter(rima(:,:,i),5,2,sigma);
    end
end
 
% show results
subplot(1,3,1),imshow(uint8(ima)),title('original');
subplot(1,3,2),imshow(uint8(rima)),title('noisy');
subplot(1,3,3),imshow(uint8(fima)),title('filtered');
