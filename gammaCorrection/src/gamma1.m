clc;clear;close all;
data = textread('data\gamma.txt', '%s');
xStr = char(data(1));
yStr = char(data(2));
xC = strsplit(xStr, ',');
yC = strsplit(yStr, ',');
x = hex0x2Dec(xC);
y = hex0x2Dec(yC);
plot(x, y);
hold on;
plot([0 255], [0 1023], 'r')
xlim([0, 256]);
ylim([0, 1024]);


