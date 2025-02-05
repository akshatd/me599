%% ME599 HW1 Problem 2b

clear; clc; close all;

%% load data
get_train_test_data;
[imrows, imcols] = size(im);

%% Part 3a Eigenfaces
train_mu = mean(train_data, 2);
train_Xm = train_data - train_mu; % mean subtraced data
train_sigma = cov(train_data');

[T, lambdas] = eig(train_sigma);
[lambdas, sorted_idx] = sort(diag(lambdas), 'descend');
T = T(:, sorted_idx);

% plot mean and first 5 eigenvectors(eigenfaces/principal components)
figure;
sgtitle('HW1 P3a: Mean and First 5 Eigenfaces (Training Data)');

subplot(2, 3, 1);
% need [] to scale image values properly
% https://www.mathworks.com/help/matlab/ref/imshow.html#d126e871915
imshow(reshape(train_mu, imrows, imcols), []);
title('Mean Face');
axis image; % to make the aspect ratio of the image correct

for i = 1:5
	subplot(2, 3, i+1);
	imshow(reshape(T(:, i), imrows, imcols), []);
	title(['Eigenface ', num2str(i)]);
	axis image;
end

%% Part 3b PCA compression

recon_err = zeros(size(T, 2), 1);
m_arr = 1:size(T, 2);
denom = sum(lambdas);
for m = m_arr
	recon_err(m) = sum(lambdas(m+1:end)) / denom;
end

% find index c of m that has < 2% reconstruction error
c = find(recon_err < 0.02, 1, 'first');
fprintf('3.b: Number of principal components for < 2%% reconstruction error: %d\n', c);

% plot reconstruction error vs number of principal components
figure;
plot(m_arr(1:c+50), recon_err(1:c+50), 'LineWidth', 2);
title('HW1 P3b: Reconstruction Error vs Number of Principal Components (m)');
xlabel('Number of Principal Components (m)');
ylabel('Reconstruction Error');

% reconstruct an image using c principal components
img_idx = randi(size(data, 2));
m_arr = [1 10 c];
Xis = zeros(imrows*imcols, size(m_arr, 2));
for m = m_arr
	Xis(:, m_arr == m) = T(:, 1:m) * T(:, 1:m)' * (data(:, img_idx) - train_mu) + train_mu;
end

figure;
sgtitle("HW1 P3b: Reconstructed Image "+img_idx+" using Different Number of Principal Components");

subplot(2, 2, 1);
imshow(reshape(data(:, img_idx), imrows, imcols));
title('Original Image');
axis image;

for i = 1:3
	subplot(2, 2, i+1);
	imshow(reshape(Xis(:, i), imrows, imcols));
	title(['Reconstructed Image (m = ', num2str(m_arr(i)), ')']);
	axis image;
end

%% Part 3c plot first two PCA coefficients

Y_train = T(:, 1:c)' * train_Xm;

figure;
gscatter(Y_train(1, :)', Y_train(2, :)', train_label', [], 'o+*.xsd');
title('HW1 P3c: First Two PCA Coefficients (Training Data)');
xlabel('1st Principal Component');
ylabel('2nd Principal Component');
legend('Location', 'best');

%% Part 3d classify test data based on PCA coefficients and K-NN

test_Xm = test_data - train_mu;
K = floor(sqrt(size(train_data, 2))); % K = sqrt(N)
fprintf('3.d: K = %d\n', K);

% convert labels to integers
[class_str, ~, train_label_int] = unique(train_label);
[~, test_label_int] = ismember(test_label, class_str);

preds = zeros(c, size(test_data, 2));
errors = zeros(c, 1);
% perform knn classification for all principal components up till c
for i=1:c
	Y_train = T(:, 1:i)' * train_Xm;
	Y_test = T(:, 1:i)' * test_Xm;
	
	idx_near = knnsearch(Y_train', Y_test', 'K', K);
	% pred_label = mode(train_label_int(idx_near), 2);
	% errors(i) = sum(pred_label ~= test_label_int');
	preds(i, :) = mode(train_label_int(idx_near), 2);
	errors(i) = sum(preds(i, :) ~= test_label_int);
end

% plot classification error vs number of principal components
figure;
plot(1:c, errors, 'LineWidth', 2);
title('HW1 P3d: Classification Error vs Number of Principal Components (p)');
xlabel('Number of Principal Components (p)');
ylabel('Classification Errors');

[~, p_opt] = min(errors); % optimal number of principal components
best_pred = preds(p_opt, :);
fprintf('3.d: Optimal number of principal components: %d\n', p_opt);

% plot confusion matrix
figure;
confusionchart(test_label, class_str(best_pred), 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
title('HW1 P3d: Confusion Matrix (Test Data)');

%% Part 3e: Do LDA and get fisherfaces

C = length(class_str);
n = size(train_data, 1);
N = size(train_data, 2);
N_i = zeros(C, 1);
% get mean for all classes
train_mu_i = zeros(n, C);
for i = 1:C
	train_mu_i(:, i) = mean(train_data(:, train_label_int == i), 2);
	N_i(i) = sum(train_label_int == i);
end

% between class scatter matrix SB, normal
SB = zeros(n, n);
for i = 1:C
	SB = SB + N_i(i) * (train_mu_i(:, i) - train_mu) * (train_mu_i(:, i) - train_mu)';
end

% within class scatter matrix SW, normal
SW = zeros(n, n);
for i = 1:C
	SW = SW + (train_data(:, train_label_int == i) - train_mu_i(:, i)) * ...
		(train_data(:, train_label_int == i) - train_mu_i(:, i))';
end

% check rank of SW
fprintf('3.e: Rank of SW: %d, N-C: %d\n', rank(SW), N-C);
max_components = min(rank(SW), N-C);

% since rank(SW) < n, we need to use PCA to reduce dimensionality to N-C
Y_train = T(:, 1:max_components)' * train_Xm;

% now get SB' and SW' using Y
Y_mu_i = zeros(max_components, C);
for i = 1:C
	Y_mu_i(:, i) = mean(Y_train(:, train_label_int == i), 2);
end

SB = zeros(max_components, max_components);
for i = 1:C
	SB = SB + N_i(i) * (Y_mu_i(:, i) - mean(Y_train, 2)) * (Y_mu_i(:, i) - mean(Y_train, 2))';
end

SW = zeros(max_components, max_components);
for i = 1:C
	SW = SW + (Y_train(:, train_label_int == i) - Y_mu_i(:, i)) * ...
		(Y_train(:, train_label_int == i) - Y_mu_i(:, i))';
end

% get fisherfaces
[W_lda, lambdas_lda] = eig(SB, SW);
[lambdas_lda, sorted_idx] = sort(diag(lambdas_lda), 'descend');
W_lda = W_lda(:, sorted_idx);

% plot projection of data on first 2 fisherfaces
Y_train_fld = W_lda(:, 1:2)' * Y_train;
figure;
gscatter(Y_train_fld(1, :)', Y_train_fld(2, :)', train_label', [], 'o+*.xsd');
title('HW1 P3e: First Two Linear Discriminant Coefficients (Training Data)');
xlabel('1st Fisherface Component');
ylabel('2nd Fisherface Component');
legend('Location', 'best');

%% Part 3f: classify test data using fisherfaces and K-NN

W_opt = T(:, 1:max_components) * W_lda;

preds = zeros(max_components, size(test_data, 2));
errors = zeros(max_components, 1);

% perform knn classification for all fisherfaces up till max_components
for i=1:max_components
	Y_train_fld = W_opt(:, 1:i)' * train_Xm;
	Y_test_fld = W_opt(:, 1:i)' * test_Xm;
	
	idx_near = knnsearch(Y_train_fld', Y_test_fld', 'K', K);
	preds(i, :) = mode(train_label_int(idx_near), 2);
	errors(i) = sum(preds(i, :) ~= test_label_int);
end

% plot classification error vs number of fisherfaces
figure;
plot(1:10, errors(1:10), 'LineWidth', 2);
title('HW1 P3f: Classification Error vs Number of Fisherfaces (f)');
xlabel('Number of Fisherfaces (f)');
ylabel('Classification Errors');

[~, f_opt] = min(errors); % optimal number of fisherfaces
best_pred = preds(f_opt, :);
fprintf('3.f: Optimal number of fisherfaces: %d\n', f_opt);

% plot confusion matrix
figure;
confusionchart(test_label, class_str(best_pred), 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
title('HW1 P3f: Confusion Matrix (Test Data)');
