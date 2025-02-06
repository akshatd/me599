%% ME599 HW2 P1
clc; clear all; close all;

% load data
load('X_data.mat');

% plot data
hist_bins = 40; % tune this so there is a clear separation in the middle
figure;
histogram(X, hist_bins, 'Normalization', 'pdf', 'DisplayName', 'Data');
hold on;
xlabel('X'); ylabel('Probability Density');

% get bins from histogram to pick the one that separates the data in the middle
ax = gca;
[counts, edges] = myHistcounts(ax);
null_bins = find(counts == 0); % find bins with nothing
[~, split_bin_idx] = min(null_bins - hist_bins/2); % find bin closest to the middle
% find the middle of that bin and split data
split = (edges(null_bins(split_bin_idx))+edges(null_bins(split_bin_idx)+1))/2;

X1 = X(find(X < split)); X2 = X(find(X >= split));
X1_mean = mean(X1); X2_mean = mean(X2);
X1_std = std(X1); X2_std = std(X2);
fprintf('HW2 P1: E[X1] = %.2f, E[X2] = %.2f\n', X1_mean, X2_mean);

test = 9.9;
P_X1 = MyNormpdf(test, X1_mean, X1_std) * 100;
P_X2 = MyNormpdf(test, X2_mean, X2_std) * 100;
fprintf('HW2 P1: P(X1) = %.2f, P(X2) = %.2f\n', P_X1, P_X2);

% plot pdf estimates
range = 0:0.01:max(X);
X1_pdf = MyNormpdf(range, X1_mean, X1_std);
X2_pdf = MyNormpdf(range, X2_mean, X2_std);
plot(range, X1_pdf, 'r', 'LineWidth', 2, 'DisplayName', 'Estimated PDF X1');
plot(range, X2_pdf, 'b', 'LineWidth', 2, 'DisplayName', 'Estimated PDF X2');
xline(test, 'k--', 'LineWidth', 1.5, 'DisplayName', "Test value, x=" + test);

title('HW2 P1: PDF Estimates with underlying data');
legend('location', 'best');

function prob = MyNormpdf(x, mu, sigma)
prob = 1/(sigma*sqrt(2*pi)) * exp(-0.5*((x-mu)/sigma).^2);
end

function [counts, edges] = myHistcounts(ax)
% get histogram counts and edges
counts = ax.Children.Values;
edges = ax.Children.BinEdges;
end
