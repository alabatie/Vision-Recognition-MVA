function[H] = computeH(sample)

N=size(sample,2); %number of corresponding points

a=cell(1,N);
for(j=1:N)
    x1=sample(1,j);
    y1=sample(2,j);
    x2=sample(3,j);
    y2=sample(4,j);
    a{j}=[-x1,-y1,-1,0,0,0,x2*x1,x2*y1,x2;0,0,0,-x1,-y1,-1,y2*x1,y2*y1,y2];
end

A=[];
for(j=1:N)
    A=[A;a{j}];
end

[U,S,V]=svd(A);
H=V(:,9)';