function [id,frame,x,y,sigma1,intensity,offest,bkgstd,uncertainty] = pointsFromTS(filename)

data = dlmread(filename,',',1,0);

id = data(:,1);
frame = data(:,2);
x = data(:,3);
y = data(:,4);
sigma1 = data(:, 5);
intensity = data(:, 6);
offest = data(:,7);
bkgstd = data(:,8);
uncertainty = data(:,9);

end