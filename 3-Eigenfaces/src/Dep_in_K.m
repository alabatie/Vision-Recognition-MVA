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

display_faces(components,10,10); 
title ('Top principal components');

%Baseline
fprintf('Calculate Baseline... ');
[nn_ind_cc, estimated_label_cc] = ncc(test_data,train_data,train_label);
fprintf('%f\n', sum(estimated_label_cc == test_label)/n_test);

%Loop for dependency in K
N=10;
class=zeros(N,1);
Ncomp=zeros(N,1);
base=sum(estimated_label_cc == test_label)/n_test*ones(N,1);

for(i=1:N)
    K=i^2;
    Ncomp(i)=K;
    train_data_pca = train_data*components(:,1:K); % low-dim coefficients for training data (projection onto components)
    train_data_reconstructed = train_data_pca*components(:,1:K)'; % high-dimensional faces reconstructed from the low-dim coefficients

    fprintf('Projecting test data K=%u...\n',K);
    test_data_pca = test_data*components(:,1:K); % low-dim coefficients for test data
    test_data_reconstructed = test_data_pca*components(:,1:K)'; % high-dimensional reconstructed test faces

    fprintf('Running nearest-neighbor classifier...\n');

    [nn_ind, estimated_label] = nn(test_data_pca,train_data_pca,train_label); % output of nearest-neighbor classifier:
    % nearest neighbor training indices for each training point and 
    % estimated labels (corresponding to labels of the nearest neighbors)
    
    class(i)=sum(estimated_label == test_label)/n_test;
    fprintf('Classification rate: %f\n', class(i));
end   
 

plot(Ncomp,[class base]);
figure;
semilogx(Ncomp,[class base]);
