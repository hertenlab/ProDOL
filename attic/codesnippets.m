% split transformation matrix in separate transformations

translation = tform.T(3,1:2);
rotation = asin(tform.T(2,1));
scaling = [tform.T(1,1) / cos(rotation), tform.T(2,2) / cos(rotation)];

