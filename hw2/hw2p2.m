%% ME599 HW2 P2
clc; clear all; close all;

% load data
load('X_1.mat');
load('X_2.mat');

% augment data
X = [X_1, X_2; ones(1, size(X_1, 2) + size(X_2, 2))];

% labels
Z = [ones(1, size(X_1, 2)), -ones(1, size(X_2, 2))];

%% P2a Perceptron
W_hat_0 = rand(3, 1); % random weights
options = optimoptions('fmincon', 'SpecifyObjectiveGradient', true);
W_opt = fmincon(@(W) perceptronCostWGrad(X, Z, W), W_hat_0, [],[],[],[],[],[],[], options); % optimize weights
fprintf('Equation of Perceptron hyperplane: x2 = %fx1 + %f\n', -W_opt(1)/W_opt(2), -W_opt(3)/W_opt(2));

% plot
x1_min = min(X(1, :)); x1_max = max(X(1, :));
x1 = x1_min:0.01:x1_max;
x2 = lineFromWights(W_opt, x1);

figure;
scatter(X_1(1, :), X_1(2, :), 'filled', 'DisplayName', 'Class 1');
hold on;
scatter(X_2(1, :), X_2(2, :), 'filled', 'DisplayName', 'Class 2');
plot(x1, x2, 'k', 'LineWidth', 1, 'DisplayName', 'Separating hyperplane(Perceptron)');
xlabel('x1'); ylabel('x2');
title('HW2 P2a: Separating hyperplane using Perceptron');
legend('Location', 'best');

%% P2b SVM
W_hat_0 = rand(3, 1); % random weights
H = eye(3);
% H(3, 3) = 0; % only penalize weights, not bias
f = zeros(3, 1);
A = -Z'.*X'; b = -ones(size(Z));
W_opt = quadprog(H, f, A, b); % optimize weights
fprintf('Equation of SVM hyperplane: x2 = %fx1 + %f\n', -W_opt(1)/W_opt(2), -W_opt(3)/W_opt(2));

% plot
x2 = lineFromWights(W_opt, x1);

figure;
scatter(X_1(1, :), X_1(2, :), 'filled', 'DisplayName', 'Class 1');
hold on;
scatter(X_2(1, :), X_2(2, :), 'filled', 'DisplayName', 'Class 2');
plot(x1, x2, 'k', 'LineWidth', 1, 'DisplayName', 'Separating hyperplane(SVM)');
xlabel('x1'); ylabel('x2');
title('HW2 P2b: Separating hyperplane using SVM');
legend('Location', 'best');

%% P2a Perceptron Cost Function
function [cost, grad] = perceptronCostWGrad(X, Z, W)
% X: data (n x N)
% Z: labels (N x 1)
% W: weights (n x 1)
loss_cost = Z.*(W'*X); % loss function, -ve if misclassified
cost = -sum(loss_cost(loss_cost < 0)); % want cost +ve if missclassified
loss_grad = Z.*X;
grad = -sum(loss_grad(:, loss_cost < 0), 2);
end

%% Function for plotting line from weights for decision boundary
function x2 = lineFromWights(W, x1)
x2 = -(W(1)*x1 + W(3))/W(2);
end