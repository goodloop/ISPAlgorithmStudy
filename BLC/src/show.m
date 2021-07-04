function show(orgData, corData, bitsNum, mean)
% show.m    Data visualization
%   Input:
%       orgData     the org img data 	 
%       corData     the corrected data of img
%       bitsNum      the count of bits
%   Output:
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-06-30
% Note: 
    yMax = 2^bitsNum;
    listOrgData = orgData(:);
    listCorData = corData(:);
    figure;
    subplot(221);
    
    imshow(orgData);
    title('orgDta');
    subplot(222);
    
    imshow(uint8(corData));
    title('corData');
    subplot(223)
    
    plot(listOrgData(listOrgData<(mean+10)))
    title('org pixel value');
    ylim([-10 yMax]);
    subplot(224);
    
    plot(listCorData(listCorData<(yMax*10/255)));
    title('cor pixel value');
    ylim([-10 yMax]);
end