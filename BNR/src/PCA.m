r = normrnd(0,1,[10000 3]); 
x1 = r(:,1);
y1 = r(:,2);

figure();
plot(x1, y1,  'r.')
hold on;


A = [1 8 3; 2 8 4; 4 5 8];
R = r*A;
x2 = R(:,1);
y2 = R(:,2);

plot(x2, y2, 'y.')
