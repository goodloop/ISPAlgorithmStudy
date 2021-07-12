t=-pi/4:0.01:pi/4;
[x, y] = meshgrid(t);
z=cos(sqrt(x.^2+y.^2)).^4;
mesh(x, y, z)