%%
%% Template for PCA-based face recognition
%%

fprintf('\n Loading data...\n');
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

display_faces(components,10,10); 
title ('Top principal components');


K=100;
train_data_pca = train_data*components(:,1:K); % low-dim coefficients for training data (projection onto components)
train_data_reconstructed = train_data_pca*components(:,1:K)'; % high-dimensional faces reconstructed from the low-dim coefficients

fprintf('Projecting test data...\n');
test_data_pca = test_data*components(:,1:K); % low-dim coefficients for test data
test_data_reconstructed = test_data_pca*components(:,1:K)'; % high-dimensional reconstructed test faces

fprintf('Running nearest-neighbor classifier...\n');

[nn_ind, estimated_label] = nn(test_data_pca,train_data_pca,train_label); % output of nearest-neighbor classifier:
[nn_ind_cc, estimated_label_cc] = nn(test_data,train_data,train_label);
% nearest neighbor training indices for each training point and 
% estimated labels (corresponding to labels of the nearest neighbors)

fprintf('Classification rate: %f\n', sum(estimated_label == test_label)/n_test);

fprintf('Baseline: %f\n', sum(estimated_label_cc == test_label)/n_test);

%%
%% display incorrect matches
%%
figure;
index=1;
N_incorrect= sum(estimated_label ~= test_label);

for batch = 1:10
    for i = 1:12
        test_ind = (batch-1)*12+i;
        if estimated_label(test_ind)~=test_label(test_ind)      
            subplot(4,N_incorrect,index);
            imshow(reshape(test_data(test_ind,:),[32 32]),[]);
            if index == 6
                title('Orig. test img.');
            end
            subplot(4,N_incorrect,index+N_incorrect);
            imshow(reshape(test_data_reconstructed(test_ind,:),[32 32]),[]);
            if index == 6
                title('Low-dim test img.');
            end
            subplot(4,N_incorrect,index+2*N_incorrect);
            imshow(reshape(train_data_reconstructed(nn_ind(test_ind),:),[32 32]),[]);
            if index == 6
                title('Low-dim nearest neighbor');
            end
            subplot(4,N_incorrect,index+3*N_incorrect);
            imshow(reshape(train_data(nn_ind(test_ind),:),[32 32]),[]);
            if index == 6
                title('Orig. nearest neighbor');
            end
            xlabel('incorrect');
            index=index+1;
        end
    end
end

