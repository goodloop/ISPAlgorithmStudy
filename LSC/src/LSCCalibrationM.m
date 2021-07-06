function LSCCalibrationM(path)
% LSCCalibrationM.m    get gainMat of lsc
%   Input:
%       path    the path of refImage 
%   Output:
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-07-05
% Note: 
lscRefImg = double(imread(path));
tmp = ones(size(lscRefImg));
corTab = (tmp./lscRefImg) * 0.8 * max(max(lscRefImg));
save('src/corTab.mat', 'corTab');
end

