%% --------------------------------
%% author:wtzhu
%% email:wtzhu_13@163.com
%% date: 20211012
%% fuction: Non-Local Means
%% --------------------------------
close all;
clear all;
clc
img = imread('./images/lena.bmp');
I = double(imresize(img, [32, 32]));
% figure();
% imshow(uint8(I));
I_noise=I+10*randn(size(I));
% figure();
% imshow(uint8(I_noise));

log_file = fopen('log.txt','w+');

tic
ds = 2;
Ds = 5;
h = 10;

[m,n]=size(I_noise);
DenoisedImg=zeros(m,n);
PaddedImg = padarray(I,[ds,ds],'symmetric','both');
kernel=ones(2*ds+1,2*ds+1);
kernel=kernel./((2*ds+1)*(2*ds+1));
h2=h*h;

for i=1:m
    disp('*******************');
    for j=1:n
        num = 0;
        fprintf(log_file,'=====================');
        fprintf(log_file,'\r\n');
        i1=i+ds;
        j1=j+ds;
        W1=PaddedImg(i1-ds:i1+ds,j1-ds:j1+ds);  %邻域窗口1
        fprintf('中心点：(%d, %d)', i, j);
        fprintf(log_file, '中心点：(%d, %d)', i, j);
        fprintf(log_file,'\r\n');
        fprintf(log_file, '当前窗口：%d, %d, %d, %d', i1-ds, i1+ds, j1-ds, j1+ds);
        fprintf(log_file,'\r\n');
        
        wmax=0;
        average=0;
        sweight=0;
        
        %%搜索窗口
        rmin = max(i1-Ds,ds+1);
        rmax = min(i1+Ds,m+ds);
        smin = max(j1-Ds,ds+1);
        smax = min(j1+Ds,n+ds);
        
        for r=rmin:rmax
            fprintf(log_file,'****************');
            fprintf(log_file,'\r\n');
            for s=smin:smax
               
                if(r==i1&&s==j1)
                continue;
                end
                W2=PaddedImg(r-ds:r+ds,s-ds:s+ds);%邻域窗口2
                fprintf(log_file, '参考窗口：%d, %d, %d, %d', r-ds, r+ds, s-ds, s+ds);
                fprintf(log_file,'\r\n');
                num = num + 1;
                Dist2=sum(sum(kernel.*(W1-W2).*(W1-W2)));%邻域间距离
                w=exp(-Dist2/h2);
                if(w>wmax)
                    wmax=w;
                end
                sweight=sweight+w;
                average=average+w*PaddedImg(r,s);
            end
        end
        disp('==========');
        fprintf('搜索窗口数量：%d\n', num);
        average=average+wmax*PaddedImg(i1,j1);%自身取最大权值
        sweight=sweight+wmax;
        DenoisedImg(i,j)=average/sweight;
    end
end
fclose(log_file);
figure();
imshow(uint8(DenoisedImg));
toc
