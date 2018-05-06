image_color=imread('butterfly.jpg');
image=mean(image_color,3);
image_downsampling=image;
[h,w]=size(image);
GlobalMaxLaplacian=0;
% O octaves with N levels for the laplacian, increment represents "k"
sigma0=2; O=3; N=5; inc=2^(1/N);

%Inline functions
bin_fun = inline('bin_fun2(x,1)','x'); %Second argument is the threshold if we do not use relative threshold
max_fun = inline('max(x)','x');

%Laplacian variables
Laplacian = cell(O,1);
max2DLaplacian= cell(O,1);
max3DLaplacian= cell(O,1);
bin2DLaplacian= cell(O,1);

for(j=1:O)
    Laplacian{j}=cell(1,N);
    max2DLaplacian{j}=cell(1,N);
    bin2DLaplacian{j}=cell(1,N);
    max3DLaplacian{j}=cell(1,N);
    j
    
    %define first image of the octave
    if(j==1) %First octave we start from the normal size
        
        first_image = image;
        gauss = fspecial('gaussian', [round(3*sigma0),round(3*sigma0)], sigma0);
        upper_image = imfilter(image, gauss, 'symmetric');
        sigma=sigma0; 
    else  %Other octaves we downsample     
        h2=int_part(h/(2^(j-1)));
        w2=int_part(w/(2^(j-1)));
        first_image=zeros(h2,w2);
        lower_image=zeros(h2,w2);
        temp=zeros(h2,w);
        
        %Smooth a little before downsampling
        sigma=0.6*2^(j-1); 
        gauss = fspecial('gaussian', [round(5*sigma), round(5*sigma)], sigma);
        image_downsampling = imfilter(image, gauss, 'symmetric');
        
        %Downsampling
        for(k=1:h2)
            temp(k,:)=image_downsampling((2^(j-1))*k,:);
        end
        
        for(l=1:w2)
            first_image(:,l)=temp(:,(2^(j-1))*l);
        end
        
        sigma=sigma0; %sigma starts again from sigma0 because we have downsampled
        gauss = fspecial('gaussian', [round(5*sigma0),round(5*sigma0)], sigma0);
        upper_image = imfilter(first_image, gauss, 'symmetric'); 
    end
    
    
    %build Laplacians in the octave
    for(i=1:N+2) %i goes to N+2 so we can detect maximums from i=2 to i=N+1
        
        %Compute lower and upper images
        lower_image = upper_image;
        sigma=sigma*inc;
        gauss = fspecial('gaussian', [round(5*sigma),round(5*sigma)], sigma);
        upper_image = imfilter(first_image, gauss, 'symmetric');   
        
        %Compute Laplacian square
        Laplacian{j}{i}=upper_image - lower_image;
        Laplacian{j}{i}=Laplacian{j}{i}.*Laplacian{j}{i};
    
        %Compute Laplacian square maximums
        max2DLaplacian{j}{i} = colfilt(Laplacian{j}{i},[3, 3],'sliding',max_fun);
        bin2DLaplacian{j}{i} = colfilt(Laplacian{j}{i},[3, 3],'sliding',bin_fun);
        
        %Find global maximum of Laplacian
        if(i>1 & i<N+2)
            temp=max_fun(max_fun(max2DLaplacian{j}{i}));
            if(temp>GlobalMaxLaplacian)
               GlobalMaxLaplacian=temp;
            end
        end
        
    end    
    
end


%Compute 3D max Laplacians
t=0.4*GlobalMaxLaplacian; %Set relative thresold

for(j=1:O)
    for(i=1:N)
      max3DLaplacian{j}{i}=max3D_fun(bin2DLaplacian{j}{i+1},max2DLaplacian{j}{i},max2DLaplacian{j}{i+1},max2DLaplacian{j}{i+2},t);          
  end
end


%Construct Blob vector
Nb_Blob=0;
for(j=1:O)
    for(i=1:N)
      Nb_Blob=Nb_Blob+sum(sum(max3DLaplacian{j}{i}));
  end
end
Nb_Blob

Blob=zeros(3,Nb_Blob); %Each blob gives a 3 components vector, 2 for the position in the image, 1 for sigma
index=1;
for(j=1:O)    
    for(i=1:N)
        if(sum(sum(max3DLaplacian{j}{i}))~=0) %Check that there are maximums in octave j and i^th increment
            [h,w]=size(max3DLaplacian{j}{i});
            for(k=1:h)
                if(sum(max3DLaplacian{j}{i}(k,:))~=0) %Check that there are maximums in the k^th row of the image
                    for(l=1:w)
                        if(max3DLaplacian{j}{i}(k,l)==1)
                            Blob(:,index)= [2^(j-1) *k; 2^(j-1) *l; sigma0*2^(j-1)*inc^i];
                            index=index+1;
                        end
                    end
                end
            end
        end
    end                
end

'Blob vector created'

%Draw Blob circles
for(j=1:Nb_Blob)
    image_color=circle_fun(image_color,Blob(:,j));
end

imshow(uint8(image_color));
