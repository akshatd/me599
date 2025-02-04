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

% plot confusion matrix
figure;
confusionchart(test_label, class_str(best_pred), 'RowSummary', 'row-normalized', 'ColumnSummary', 'column-normalized');
title('HW1 P3d: Confusion Matrix (Test Data)');

