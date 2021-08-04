function decValueList =  hex0x2Dec(hexCell)
% hex0x2Dec.m        Convert a string which contains '0x' and is a hexadecimal value to adecimal  
%   Input:
%       hexCell        cell format       
%   Output:
%       decValueList   int format    
%   Instructions:
%       author:     wtzhu
%       e-mail:     wtzhu_13@163.com
% Last Modified by wtzhu v1.0 2021-08-04
% Note: 
    n = size(hexCell);
    decValueList =zeros(n);
    for i = 1: n(2)
       valueStr = char(hexCell(i));
       decValue = hex2dec(valueStr(3:end));
       decValueList(1, i) = decValue;
    end
end