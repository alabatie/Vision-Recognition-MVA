function[desc,desc_pos]= features(image_name,t)
    
image_color=imread(image_name);
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
for(j=1:O)
    for(i=1:N)
      max3DLaplacian{j}{i}=max3D_fun(bin2DLaplacian{j}{i+1},max2DLaplacian{j}{i},max2DLaplacian{j}{i+1},max2DLaplacian{j}{i+2},t);          
  end
end


%Construct vector of features
Nb_desc=0;
for(j=1:O)
    for(i=1:N)
      Nb_desc=Nb_desc+sum(sum(max3DLaplacian{j}{i}));
  end
end

%Extract positions
desc_pos2=zeros(2,Nb_desc); 
index=0;
for(j=1:O)    
    for(i=1:N)
        if(sum(sum(max3DLaplacian{j}{i}))~=0) %Check that there are maximums in octave j and i^th increment
            [h1,w1]=size(max3DLaplacian{j}{i});
            for(k=1:h1)
                if(sum(max3DLaplacian{j}{i}(k,:))~=0) %Check that there are maximums in the k^th row of the image
                    for(l=1:w1)
                        if(max3DLaplacian{j}{i}(k,l)==1)
                            index=index+1;
                            desc_pos2(:,index)=[2^(j-1) *l;2^(j-1) *k]; %Change the order of the coordinated, first x horizontal, then y vertical
                        end
                    end
                end
            end
        end
    end                
end

%Extract descriptors
desc=zeros(64,Nb_desc);
index=0;
gauss = fspecial('gaussian', [10,10], 5);
desc_pos=desc_pos2;

blur_image = imfilter(image, gauss, 'symmetric');
for(i=1:Nb_desc)
    x=desc_pos2(1,i); %[y,x]=desc_pos2(i,:) doesn't work here I don't know why
    y=desc_pos2(2,i);
    if(y>=20 & y<=h-20 & x>=20 & x<=w-20)
        index=index+1;
        for(k=0:7)
            for(l=0:7)
                desc(8*k+l+1,index)=blur_image(y-17+5*k,x-17+5*l); %Sample every 5 pixels in blurred image
            end
        end
    else
        desc_pos(:,index+1)=[];
    end
    
end

%Extract non-zero components(corresponding to features not on the border)
Nb_desc=index;
desc=desc(:,1:Nb_desc);

%Normalise every descriptor
for(i=1:Nb_desc)
    m=mean(desc(:,i));
    s=sqrt(var(desc(:,i)));
    if(s~=0)
        desc(:,i)=1/s*(desc(:,i)-m*ones(64,1));
    else
        desc(:,i)=[];
        Nb_desc=Nb_desc-1;
    end
end

            
            