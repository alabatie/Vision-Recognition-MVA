function result = bin_fun2(x,threshold)

result=double(x(round(size(x,1)/2),:)>=max(x)).*double(x(round(size(x,1)/2),:)>=threshold);