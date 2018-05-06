function [neighbor,label]=nn(mat1,mat2,train_label)
[h1,w]=size(mat1);
[h2,w]=size(mat2);
neighbor=zeros(h1,1);
label=zeros(h1,1);

for(i=1:h1)
    min=100000;
    minIndex=0;
    for(j=1:h2)
        if(dot(mat1(i,:)-mat2(j,:),mat1(i,:)-mat2(j,:))<min)
            min=dot(mat1(i,:)-mat2(j,:),mat1(i,:)-mat2(j,:));
            minIndex=j;
        end
    end
    
    neighbor(i)=minIndex;
    label(i)=train_label(minIndex);
end