function[match] = match_desc(desc1, pos1, desc2, pos2,matchingT) %desc2 correspondons to reference image

%Check sizes
if(size(desc1,2)~=size(pos1,2) | size(desc2,2)~=size(pos2,2))
    fprintf('Desciptors and positions of descriptors do not have same number of entries');
end

N1=size(desc1,2);
N2=size(desc2,2);
INF=10000;
Nb_match=0;
match=zeros(4,N1); %List of matched point from image1 with position in image 1 and position in image 2 so 4 coordinates

for(i=1:N1)
    min=INF;
    min2=INF;
    minIndex=0;
    
    for(j=1:N2)
        if(min>dist2(desc1(:,i)',desc2(:,j)'))
            min2=min; %Second minimum got affected the minimum value for 1:j-1, that is the second minimum for 1:j
            min=dist2(desc1(:,i)',desc2(:,j)');
            minIndex=j;
        else
            if(min2>dist2(desc1(:,i)',desc2(:,j)'))
                min2=dist2(desc1(:,i)',desc2(:,j)'); %If the value is not a global minimum but is lower than the current second minimum we affect it to min2
            end
        end
    end
      
    if(min2>=matchingT*min)
        Nb_match=Nb_match+1;
        match(:,Nb_match)=[pos1(1,i); pos1(2,i); pos2(1,minIndex); pos2(2,minIndex)];
    end
end

match=match(:,1:Nb_match);
        
