%% ME599 HW2 P3
clc; clear all; close all;

% load data
[train_data, train_label, test_data, test_label] = getData();

%% visualize random image
% figure;
% idx = randi(size(test_data, 2));
% img = reshape(test_data(:, idx), 28, 28);
% imshow(img);
% title(["HW2 P3 Random Image", "Label: ", num2str(find(test_label(:, idx) == 1))]);

%% initialize weights an biases
C = 3;
n_x = size(train_data, 1);
n_yhat = C;
N = size(train_data, 2);

n_hidden = 100;

W1 = randn(n_x, n_hidden);
W1_0 = randn(n_hidden, 1);
W2 = randn(n_hidden, n_yhat);
W2_0 = randn(n_yhat, 1);

eta = 0.1; % learning rate

%% training loop
loss_all = [];
num_iters = 1000;
for iter = 1:num_iters
	loss = 0;
	
	dldW1 = zeros(size(W1));
	dldW1_0 = zeros(1, size(W1_0, 1));
	dldW2 = zeros(size(W2));
	dldW2_0 = zeros(1, size(W2_0, 1));
	
	for i = 1:N
		% forward pass
		O1 = sig(W1'*train_data(:, i) + W1_0);
		yhat = soft(W2'*O1 + W2_0);
		
		loss = loss + cross_entropy(train_label(:, i), yhat);
		
		% backward pass
		dldyhat = -(train_label(:, i)./yhat)';
		dyhatdz = diag(yhat) - yhat*yhat';
		dldz = dldyhat*dyhatdz;
		
		dldW2 = dldW2 + O1*dldz;
		dldW2_0 = dldW2_0 + dldz;
		dldO1 = dldz*W2';
		
		dO1dz = diag(O1) .* (1-O1);
		dldz = dldO1*dO1dz;
		
		dldW1 = dldW1 + train_data(:, i)*dldz;
		dldW1_0 = dldW1_0 + dldz;
		
	end
	
	% update weights
	W1 = W1 - eta*dldW1/N;
	W1_0 = W1_0 - eta*dldW1_0'/N;
	W2 = W2 - eta*dldW2/N;
	W2_0 = W2_0 - eta*dldW2_0'/N;
	
	loss_all = [loss_all, loss/N];
end

%% plot loss
figure;
title('HW2 P3 Loss vs Iteration');
semilogy(loss_all);
xlabel('Iteration');
ylabel('Loss');

%% testing
N_test = size(test_data, 2);
correct = 0;
for i = 1:N_test
	O1 = sig(W1'*test_data(:, i) + W1_0);
	yhat = soft(W2'*O1 + W2_0);
	[~, pred] = max(yhat);
	[~, true_label] = max(test_label(:, i));
	if pred == true_label
		correct = correct + 1;
	end
end

accuracy = correct/N_test;
fprintf('HW2 P3 Test Accuracy: %.2f%%\n', accuracy*100);

function Y = soft(X)
Y = exp(X)./ (sum(exp(X)));
end

function Y = sig(X)
Y = 1./(1+exp(-X));
end

function e = cross_entropy(Y, Yhat)
e = -Y'*log(Yhat);
end

function [train_data, train_label, test_data, test_label] = getData()
num_classes = 3;
class_labels = eye(num_classes);
data_dir = './Reduced_MNIST_Data/';

idx = 1;
% get training data
for i = 1:num_classes
	file_pattern = fullfile(data_dir, ['train/', num2str(i), '/*.jpg']);
	img_files = dir(file_pattern);
	num_files = length(img_files);
	for j = 1:num_files
		img = imread([img_files(j).folder, '/', img_files(j).name]);
		train_data(:, idx) = double(img(:))/255;
		train_label(:, idx) = class_labels(i, :)';
		idx = idx + 1;
	end
end
% randomize training data
idx = randperm(size(train_data, 2));
train_data = train_data(:, idx);
train_label = train_label(:, idx);

idx = 1;
% get testing data
for i = 1:num_classes
	file_pattern = fullfile(data_dir, ['test/', num2str(i), '/*.jpg']);
	img_files = dir(file_pattern);
	num_files = length(img_files);
	for j = 1:num_files
		img = imread([img_files(j).folder, '/', img_files(j).name]);
		test_data(:, idx) = double(img(:))/255;
		test_label(:, idx) = class_labels(i, :)';
		idx = idx + 1;
	end
end

end