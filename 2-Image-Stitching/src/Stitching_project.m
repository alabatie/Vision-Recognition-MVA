image1='keble_a.jpg';
image2='keble_b.jpg';
image3='keble_c.jpg';

%Parameters
matchingT=1.5; %Second minimum needs to be 1.5 times greater than first minimum
ransacI=500; %Nb iterations in RANSAC
inlierT=0.0001; %Inlier threshold for the value of ||[ax;ay]*h||² as in the note of David Kriegman
LaplacianT=20; %Threshold on value of Laplacian for detecting features (with image intensities ranging in 0:255)
fprintf('\n\nStitching with parameters: \n%u RANSAC iterations \n%f for matching Threshold \n%f for inlier Threshold\n',ransacI,matchingT,inlierT);

%Detect features
fprintf('\nDetecting features...');
tic;
[desc1,pos1]=features(image1,LaplacianT);
[desc2,pos2]=features(image2,LaplacianT);
[desc3,pos3]=features(image3,LaplacianT);
fprintf('%f sec \n',toc);

%Nb of features detected
fprintf('%u features detected in image1 \n',size(desc1,2));
fprintf('%u features detected in image2 \n',size(desc2,2));
fprintf('%u features detected in image3 \n',size(desc3,2));

%Restrict the number of features if there are too much for time issue
maxN=400;
if(size(desc1,2)>=maxN)
    desc1=desc1(:,1:maxN);
    pos1=pos1(:,1:maxN);
end
if(size(desc2,2)>=maxN)
    desc2=desc2(:,1:maxN);
    pos2=pos2(:,1:maxN);
end
if(size(desc3,2)>=maxN)
    desc3=desc3(:,1:maxN);
    pos3=pos3(:,1:maxN);
end

%Put in correspondence
fprintf('\nFinding nearest neighbours...');
tic;
match12=match_desc(desc1,pos1,desc2,pos2,matchingT);
match32=match_desc(desc3,pos3,desc2,pos2,matchingT);
fprintf('%f sec \n',toc);

%Number of tentative correspondences
fprintf('%u tentative correspondences between images 1 & 2 \n',size(match12,2));
fprintf('%u tentative correspondences between images 2 & 3 \n',size(match32,2));

%Show tentative correspondences for images 1 & 2
figure; imagesc(imread(image2)); hold on;
line([match12(1,:);match12(3,:)],[match12(2,:); match12(4,:)],'color','y')
plot(match12(3,:),match12(4,:),'+g');

%Find homographies
fprintf('\nFinding homographies with RANSAC...');
tic;
[h12,match12]=RANSAC(match12,ransacI,inlierT);
[h32,match32]=RANSAC(match32,ransacI,inlierT);
h12=h12';
h32=h32';
H12=[h12(1), h12(2), h12(3); h12(4), h12(5), h12(6);h12(7), h12(8), h12(9)];
H32=[h32(1), h32(2), h32(3); h32(4), h32(5), h32(6);h32(7), h32(8), h32(9)];
fprintf('%f sec \n',toc);

%Number of inliers
fprintf('%u of inliers for images 1 & 2 \n',size(match12,2));
fprintf('%u of inliers for images 2 & 3 \n',size(match32,2));

%Show correspondences after Ransac for images 1 & 2
figure; imagesc(imread(image2)); hold on;
line([match12(1,:);match12(3,:)],[match12(2,:); match12(4,:)],'color','y')
plot(match12(3,:),match12(4,:),'+g');

%Warp images
fprintf('\nWarping images...');
tic;
figure;
bbox = [-400 1200 -200 700]; % image space for mosaic
Im2w = vgg_warp_H(double(imread(image2)), eye(3), 'linear', bbox); % warp image 1 to mosaic image
Im1w = vgg_warp_H(double(imread(image1)), H12, 'linear', bbox);
Im3w = vgg_warp_H(double(imread(image3)), H32, 'linear', bbox);
imagesc(double(max(max(Im1w,Im2w),Im3w))/255);
fprintf('%f sec \n\n\n',toc);
