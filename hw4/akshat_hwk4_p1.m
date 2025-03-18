%% ME599 HW4 Problem 1
clc; clear; close all;

%% part a, proving operator G is linear
% Load example voltage as V1
load('V_example.mat');
V1 = V_example';
N = length(V1);
tspan = 0.1*(1:N);

% generate some weird shit as V2
V2 = (sin(tspan)+1) * max(V1)/4; % scale to be half the height as V1
V2(173:end) = 0; % zeros after last full sine wave

a1 = -0.23;
a2 = 1.14;
V12 = a1*V1+a2*V2;

% plot input voltages
fig = figure;
plot(tspan, V1, LineWidth=1.5, DisplayName='$V_1$');
hold on;
plot(tspan, V2, LineWidth=1.5, DisplayName='$V_2$');
plot(tspan, V12, '--', LineWidth=1.5, DisplayName='$a_1V_1+a_2V_2$')
ylabel('$V(V)$', 'Interpreter', 'latex')
xlabel('$t(\mu s)$', 'Interpreter', 'latex')
legend('Location', 'best', 'Interpreter', 'latex');
title("HW4P1a: Input Voltages");
saveas(fig, 'figs/hw4p1a_volts.svg');

% get outputs for all possible inputs
P1 = piezo_nozzle(V1, N);
P2 = piezo_nozzle(V2, N);
P12 = piezo_nozzle(V12, N);
P12_alt = a1*P1 + a2*P2;

% plot outputs
fig = figure;
plot(tspan, P1, LineWidth=1.5, DisplayName='$P_1$');
hold on;
plot(tspan, P2, LineWidth=1.5, DisplayName='$P_2$');
plot(tspan, P12, LineWidth=1.5, DisplayName='$P_{12}$');
plot(tspan, P12_alt, '--', LineWidth=1.5, DisplayName='$P_a$');
ylabel('$P(kPa)$', 'Interpreter', 'latex');
xlabel('$t(\mu s)$', 'Interpreter', 'latex')
legend('Location', 'best', 'Interpreter', 'latex');
title("HW4P1a: Output Pressure");
saveas(fig, 'figs/hw4p1a_press.svg');
