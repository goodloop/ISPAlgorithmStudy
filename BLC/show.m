function show(orgData, corData)
% show.m    Data visualization
%   Input:
%       orgData     the org img data 	 
%       corData     the corrected data of img
%   Output:
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-06-30
% Note: 
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
    
    plot(listOrgData(listOrgData<20))
    title('org pixel value');
    ylim([0 255]);
    subplot(224);
    
    plot(listCorData(listCorData<10));
    title('cor pixel value');
    ylim([0 255]);
end