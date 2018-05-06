%%
%% Template for PCA-based face recognition
%%

fprintf('\nLoading data...\n');
load('ORL_32x32.mat'); % matrix with face images (fea) and labels (gnd)
load('train_test_orl.mat'); % training and test indices (trainIdx, testIdx)
fea = double(fea / 255);

display_faces(fea,10,10);
title('Face data');
K=100;

% partition the data into training and test subset
n_train = size(trainIdx,1);
n_test = size(testIdx,1);
train_data = fea(trainIdx,:);
train_label = gnd(trainIdx,:);
test_data = fea(testIdx,:);
test_label = gnd(testIdx,:);

fprintf('Running PCA...\n');
components = princomp(fea); % find principal components (use princomp function)

%Mean face
display_faces(mean(fea),1,1);
figure;
%20 first Principal components
display_faces(components,4,5); 
title ('Top principal components');



 


