function[result] = max3D_fun(bin,max1,max2,max3,threshold) 
c1=double(max1<max2); %Matrix with 1 if the coefficient of max2 is superior than the one of max1, 0 otherwise
c2=double(max3<max2);
[h w]=size(max2);

t=double(threshold)*ones(h,w);
c3=double(max2>t);
result=bin.*c1.*c2.*c3; %Matrix with 1 if the coefficient of bin is 1, the coeff of max2 is > than the ones of max1 and max3 and is >threshold
