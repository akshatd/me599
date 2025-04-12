%% ME599 HW6 Problem 2

clc; clear; close all;

load('P_ref.mat');
load('V_example.mat');

%% part a, identify the system using ARX
ts = 0.1; % time step in microseconds
N_train = 500; % simulation duration

% generate random input
rng(1);
u_train = rand(N_train, 1) * 500; % unif rand up to 500V
y_train = piezo_nozzle(u_train,N_train); % simulate pressure evolution
mat_sysid_train = iddata(y_train, u_train, ts);

test_orders = 5:10;
num_orders = length(test_orders);
errs_man = ones(num_orders, num_orders)*Inf; % for manual system ID
errs_mat = ones(num_orders, num_orders)*Inf; % for matlab's toolbox system ID
for n_idx=1:num_orders
	for m_idx=1:n_idx
		[theta, A, b] = timeSysId(test_orders(m_idx), test_orders(n_idx), u_train, y_train);
		errs_man(m_idx, n_idx) = norm(A*theta - b);
		model_mat = arx(mat_sysid_train, [test_orders(n_idx), test_orders(m_idx), 0]);
		errs_mat(m_idx, n_idx) = model_mat.Report.Fit.MSE;
	end
end
fprintf("Manual %s\n", formattedDisplayText(errs_man,"NumericFormat","shortEng"));
fprintf("Matlab toolbox %s\n", formattedDisplayText(errs_mat,"NumericFormat","shortEng"));

m=10; n=10; % best from experiment
[theta, ~, ~] = timeSysId(m, n, u_train, y_train);
fprintf('HW6 P2a: Transfer function (Manual ARX):\n');
model_man = getModelFromTheta(m, n, theta, ts)
fprintf('HW6 P2a: Transfer function (MATLAB ARX):\n');
% arx will give in the z^-1 form, so get the num and den first
[num_mat, den_mat]= tfdata(tf(arx(mat_sysid_train, [n, m, 0])));
% flip the coefficients to get the polynomial form
model_mat = tf(fliplr(num_mat), fliplr(den_mat), ts)


% plot
N_ex = length(V_example);
tspan = ts*(1:N_ex);
P = piezo_nozzle(V_example, N_ex);
P_man = lsim(model_man, V_example, tspan);
P_mat = lsim(model_mat, V_example, tspan);

fig = figure;
yyaxis left;
hold on;
plot(tspan, P, 'g', 'LineWidth', 3, 'DisplayName', '$P$');
plot(tspan, P_man, '--b', 'LineWidth', 2, 'DisplayName', '$P_{manual}$');
plot(tspan, P_mat, '.r', 'LineWidth', 1.5, 'DisplayName', '$P_{matlab}$');
ylabel("$P(kPa)$", 'Interpreter', 'latex');
yyaxis right;
plot(tspan, V_example, 'LineWidth', 1.5, 'DisplayName', '$V_{example}$');
ylabel("$V(V)$", 'Interpreter', 'latex');
xlabel("$t(\mu s)$", 'Interpreter', 'latex');
legend('Location', 'best', 'Interpreter', 'latex');
title("HW6 P2a: Comparison between system models");
saveas(fig, 'figs/hw6p2a_vex.svg');

fig = figure;
plot(tspan, (P-P_man).^2, 'b', 'LineWidth', 1.5, 'DisplayName', '$(P-P_{manual})^2$');
hold on;
plot(tspan, (P-P_mat).^2, '--r', 'LineWidth', 1.5, 'DisplayName', '$(P-P_{matlab})^2$');
ylabel("Squared error between Pressure", 'Interpreter', 'latex');
xlabel("$t(\mu s)$", 'Interpreter', 'latex');
legend('Location', 'best', 'Interpreter', 'latex');
title("HW6 P2a: Error comparison between manual and MATLAB ARX");
saveas(fig, 'figs/hw6p2a_err.svg');

fprintf('HW6 P2a: Norm of errors from expected pressure:\n - Manual: %f \n - MATLAB: %f\n', norm(P-P_man), norm(P-P_mat));

%% part b, drive the system to P_ref
[num_mat, den_mat]= tfdata(tf(arx(mat_sysid_train, [12, 12, 0]))); % otherwise voltage is weird
model_mat = tf(fliplr(num_mat), fliplr(den_mat), ts);

% construct inpulse response matrix
ss_model = ss(model_mat);
A = ss_model.A;
B = ss_model.B;
C = ss_model.C;
N_ref = length(P_ref);

% compute last row of G first
last_row = zeros(1, N_ref);
for i=1:N_ref-1
	last_row(i) = C*A^(N_ref-i-1)*B;
end
last_row(end) = 0;

G = zeros(N_ref, N_ref);
for i=1:N_ref
	G(i, 1:i) = last_row(N_ref-i+1:end);
end

% find optimal v
V_opt = pinv(G)*P_ref;
GV_opt = piezo_nozzle(V_opt, N_ref);

% plot
tspan = ts*(1:N_ref);
fig = figure;
yyaxis left;
hold on;
plot(tspan, P_ref, 'g', 'LineWidth', 1.5, 'DisplayName', '$P_{ref}$');
plot(tspan, GV_opt, '--b', 'LineWidth', 1.5, 'DisplayName', '$\mathcal{G}(V^*(t))$');
ylabel("$P(kPa)$", 'Interpreter', 'latex');
yyaxis right;
plot(tspan, V_opt, 'LineWidth', 1.5, 'DisplayName', '$V^*(t)$');
ylabel("$V(V)$", 'Interpreter', 'latex');
xlabel("$t(\mu s)$", 'Interpreter', 'latex');
legend('Location', 'best', 'Interpreter', 'latex');
title("HW6 P2b: Optimal voltage to generate P_{ref}");
saveas(fig, 'figs/hw6p2b.svg');


function [theta, A, b] = timeSysId(m, n, u, y)
N1 = max(m,n)+1;
N2 = length(u);

% construct b
b = y(N1:N2);

% construct A
A = zeros(N2-N1+1, m+n);
% row by row
for r=1:size(A,1)
	idx_y = N1 - (1:n) + r-1;
	idx_u = N1 - (1:m) + r;
	A(r,:) = [-y(idx_y)', u(idx_u)'];
end
theta = A\b; % solve for theta
end

function model = getModelFromTheta(m, n, theta, ts)
% look at explanation in the notes
numerator = [theta(n+1:end)', zeros(1, n-m+1)]; % for b's
denominator = [1, theta(1:n)']; % for a's

model = tf(numerator, denominator, ts);
end