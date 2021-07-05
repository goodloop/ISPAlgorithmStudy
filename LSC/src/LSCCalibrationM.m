function LSCCalibrationM(path)
lscRefImg = double(imread(path));
tmp = ones(size(lscRefImg));
corTab = (tmp./lscRefImg) * 0.8 * max(max(lscRefImg));
save('src/corTab.mat', 'corTab');
end

