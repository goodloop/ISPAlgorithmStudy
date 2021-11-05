r = normrnd(0,1,[10000 3]); 
x1 = r(:,1);
y1 = r(:,2);
z1 = r(:,3);
figure();
plot3(x1, y1, z1,  '.')
hold on;


A = [1 8 3; 2 8 4; 4 5 8];
R = r*A;
x2 = R(:,1);
y2 = R(:,2);
z2 = R(:,3);

plot3(x2, y2, z2, 'y.')
