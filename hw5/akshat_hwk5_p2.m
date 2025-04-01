%% ME599 HW5 Problem 2
clc; clear; close all;

load("System_step_response.mat");

% plot output data
fig = figure;
plot(time, output, 'LineWidth', 2);
xlabel('Time (s)')
ylabel('Output');
title('HW5 P2: Step Response of the System')
saveas(fig, 'figs/hw5p2_step.svg');

% construct A and b matrices
A = [output -time];
b = -cumtrapz(time, output);

% solve for theta
theta = A \ b;
tau = theta(1);
K = theta(2);
fprintf('tau = %.3f\nK = %.3f\n', tau, K);

% plot step response
t_settle = 6*tau; % should be 4x, but do 6x to show K
t_s = time(2) - time(1);
time_tf = 0:t_s:t_settle;
model  = tf(K, [tau 1]);
[model_out, ~] = step(model, time_tf);

fig = figure;
plot(time, output, 'b', 'LineWidth', 2, 'DisplayName', 'Data');
hold on;
plot(time_tf, model_out, 'r--', 'LineWidth', 2, 'DisplayName', 'Model');
xline(tau, 'm--', 'DisplayName', "$\tau$");
yline(K, 'k--', 'DisplayName', "$K$");
xlabel('Time (s)')
ylabel('Output');
title('HW5 P2: Step response of the model vs data')
legend('Location', 'best', 'Interpreter', 'latex');
grid on;
saveas(fig, 'figs/hw5p2_step_model.svg');
