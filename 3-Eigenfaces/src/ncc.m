function [neighbor,label]=nn(mat1,mat2,train_label)
[h1,w]=size(mat1);
[h2,w]=size(mat2);
neighbor=zeros(h1,1);
label=zeros(h1,1);

for(i=1:h1)
    max=-100;
    maxIndex=0;
    for(j=1:h2)
        if(corr2(mat1(i,:),mat2(j,:))>max)
            max=corr2(mat1(i,:),mat2(j,:));
            maxIndex=j;
        end
    end
    
    neighbor(i)=maxIndex;
    label(i)=train_label(maxIndex);
end