%% --------------------------------
%% author:wtzhu
%% date: 20210202
%% fuction: 双三次插值算法sin函数的拟合函数
%% --------------------------------
function A = sw(w1)
w = abs(w1);
if w < 1 && w >= 0
   A = 1 - 2 * w^2 + w^3;  
elseif w >= 1 && w < 2
   A = 4 - 8 * w + 5 * w^2 - w^3;
else
   A = 0;
end