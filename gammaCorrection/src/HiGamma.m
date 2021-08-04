clc;clear; close all;
data = csvread('data/Gamma_Data_DEC_20210804103309.csv');
plot(data);
xlim([0, 1024]);
ylim([0, 4098]);
hold on;
plot([0, 1024], [0, 4098], 'r');