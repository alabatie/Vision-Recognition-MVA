function[h,FinalMatch] = RANSAC(match,I,T) 

N=size(match,2);
Nbinlier=zeros(I,1); %Number of inliers of iteration i
inlier=zeros(I,N); %list of inliers for iteration i
H=zeros(1,9);
max_inlier=-1;
max_index=0;
sample=zeros(4,4);

for(i=1:I)
    %Choose a sample of 4 corresponding points
    p=randperm(N);
    for(j=1:4)
        sample(:,j)=match(:,p(j));
    end
    
    %Compute homothety
    H(1,:)=computeH(sample);
    
    for(j=1:N)
        v=computeAH(match(:,j),H(1,:)');
        
        if(dist2(v',zeros(1,2)) <= T)
            Nbinlier(i)=Nbinlier(i)+1;
            inlier(i,Nbinlier(i))=j;
        end
    end
    
    if(Nbinlier(i)>max_inlier)
        max_inlier=Nbinlier(i);
        max_index=i;
    end
end

%Recompute h for from all inliers
sample=zeros(4,max_inlier);
for(j=1:max_inlier)
    sample(:,j)=match(:,inlier(max_index,j));
end

FinalMatch=sample;
h=computeH(sample);
    
    
    
