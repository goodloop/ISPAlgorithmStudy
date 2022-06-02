target_data=csvread('ReferenceColor.csv',1,0);%csvread只能读取纯数据
target_x = target_data(:, 1);
target_y = target_data(:, 2);
target_z = target_data(:, 3);
figure();
scatter3(target_x,target_y,target_z,'.')
hold on;

org_data = csvread('OriginalColor.csv',1,0);%csvread只能读取纯数据
org_x = org_data(:, 1);
org_y = org_data(:, 2);
org_z = org_data(:, 3);
scatter3(org_x, org_y, org_z, '+', 'r');
hold on;

ccm_matrix = csvread('LCC_CMC.csv');
disp(ccm_matrix);

[h, w] = size(target_data);
dst_data = org_data * ccm_matrix;
dst_x = dst_data(:, 1);
dst_y = dst_data(:, 2);
dst_z = dst_data(:, 3);
scatter3(dst_x, dst_y, dst_z, '*', 'g');
