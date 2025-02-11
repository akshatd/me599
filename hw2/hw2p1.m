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

% get h using Silverman's rule of thumb
% https://stats.stackexchange.com/questions/6670/which-is-the-formula-from-silverman-to-calculate-the-bandwidth-in-a-kernel-densi
h1 = 1.06 * min(X1_std, iqr(X1)/1.349) / length(X1)^(-1/5);
h2 = 1.06 * min(X2_std, iqr(X2)/1.349) / length(X2)^(-1/5);

test = 9.9;
P_X1 = parzWinPdf(X1, h1, test) * 100;
P_X2 = parzWinPdf(X2, h2, test) * 100;
fprintf('HW2 P1: P(X1) = %.2f, P(X2) = %.2f\n', P_X1, P_X2);

% plot pdf estimates
range = 0:0.01:max(X);
X1_pdf = zeros(size(range));
X2_pdf = zeros(size(range));
for i = 1:length(range)
	X1_pdf(i) = parzWinPdf(X1, h1, range(i));
	X2_pdf(i) = parzWinPdf(X2, h2, range(i));
end
plot(range, X1_pdf, 'r', 'LineWidth', 2, 'DisplayName', 'Estimated PDF X1');
plot(range, X2_pdf, 'b', 'LineWidth', 2, 'DisplayName', 'Estimated PDF X2');
xline(test, 'k--', 'LineWidth', 1.5, 'DisplayName', "Test value, x=" + test);

title('HW2 P1: PDF Estimates with underlying data');
legend('location', 'best');

function prob = parzWinPdf(data, h, x)
N = length(data);
d = length(x);
V = h^d;
	function in_window = windowFn(u)
		in_window = abs(u) < 0.5;
	end
prob = 1/N * sum(windowFn((data - x)/h))/V;
end

function [counts, edges] = myHistcounts(ax)
% get histogram counts and edges
counts = ax.Children.Values;
edges = ax.Children.BinEdges;
end
