%% ME599 Homework 3 Problem 2
clc; clear; close all;

% system parameters
Rm = 3.5; % Ohms, Armature resistance
Kb = 0.1; % Vs/rad, Motor back EMF constant
Kt = 0.65*Kb; % Nm/A, Motor torque constant
% Lm;  H, Armature inductance; assume 0
mp = 0.04;% kg, Spotlight(pendulum) mass
Lp = 0.1; %m, Spotlight(pendulum) length
Ip = mp*(Lp)^2;% Moment of inertia of pendulum about center of mass
Bm = 0.000008; %Nms/rad (viscous friction coefficient)
g = 9.81; %m/s^2 acceleration due to gravity

%% b: equilibrium points and stability
x1_e1 = pi/2;
x1_e2 = -pi/2;
x2_e = 0;
u_e = 0;

A1 = pendulum_fdx(0, [x1_e1; x2_e], u_e);
A2 = pendulum_fdx(0, [x1_e2; x2_e], u_e);

e1 = eig(A1);
e2 = eig(A2);

fprintf('The eigenvalues of the linearized system about the equilibrium point x1=pi/2 are:\n %.2f\n %.2f\n', e1(1), e1(2));
fprintf('The eigenvalues of the linearized system about the equilibrium point x1=-pi/2 are:\n %.2f\n %.2f\n', e2(1), e2(2));

% check stability
if real(e1(1)) < 0 && real(e1(2)) < 0
	fprintf('The equilibrium point x1=pi/2 is stable\n');
else
	fprintf('The equilibrium point x1=pi/2 is unstable\n');
end

if real(e2(1)) < 0 && real(e2(2)) < 0
	fprintf('The equilibrium point x1=-pi/2 is stable\n');
else
	fprintf('The equilibrium point x1=-pi/2 is unstable\n');
end

% perturb system
p = [-0.01; -0.01]; % perturbation
u0 = u_e;
x0 = [x1_e1; x2_e] + p;
tspan = 0:0.01:10;
[t, x] = ode45(@(t, x) pendulum_f(t, x, u0), tspan, x0);
plot_pend_states(t, x, 'HW3P2b Closed circuit dynamics (xe1)', [-4.6 1.6], [-20 20]);
[t, x] = ode45(@(t, x) pendulum_f_oc(t, x, u0), tspan, x0);
plot_pend_states(t, x, 'HW3P2b Open circuit dynamics (xe1)', [-4.6 1.6], [-20 20]);

x0 = [x1_e2; x2_e] + p;
[t, x] = ode45(@(t, x) pendulum_f(t, x, u0), tspan, x0);
plot_pend_states(t, x, 'HW3P2b Closed circuit dynamics (xe2)', [-1.585 -1.55], [-0.1 0.1]);
[t, x] = ode45(@(t, x) pendulum_f_oc(t, x, u0), tspan, x0);
plot_pend_states(t, x, 'HW3P2b Open circuit dynamics (xe2)', [-1.585 -1.55], [-0.1 0.1]);

%% c: impulse response
B = [0; Kt/(Ip*Rm)];
C = [1 0];
D = 0;
% get impulse response function(inverse laplace)
syms s
G_1 = C*inv(s*eye(2) - A1)*B+D;
g_1 = vpa(ilaplace(G_1), 3);
fprintf('The impulse response of the system about the equilibrium point x1=pi/2 is:\n');
display(g_1);
G_2 = C*inv(s*eye(2) - A2)*B+D;
g_2 = vpa(ilaplace(G_2), 3);
fprintf('The impulse response of the system about the equilibrium point x1=-pi/2 is:\n');
display(g_2);
% plot impulse response
y = impulse(ss(A1, B, C, D), tspan);
plot_impulse_resp(tspan, y, 'HW3P2c Impulse response (xe1)');
y = impulse(ss(A2, B, C, D), tspan);
plot_impulse_resp(tspan, y, 'HW3P2c Impulse response (xe2)');

%% d: controller design
% transfer function
x_c = [pi/4; 0];
As = pendulum_fdx(0, x_c, u_e);
syms s
G_s = C*inv(s*eye(2) - As)*B+D;
fprintf('The transfer function of the system about the equilibrium point x1=pi/4 is:\n');
display(G_s);
[num, den] = numden(G_s);
z = sym2poly(num);
den_coeff = sym2poly(den);
a = den_coeff(1); b = den_coeff(2); c = den_coeff(3);

% find zeta and omega
ts_max = 0.2;
os_max = 0.15;
% add a tiny amount extra so theyre greater than
zeta = -log(os_max)/sqrt(pi^2 + log(os_max)^2) + 0.0001;
omega_n = 4/(zeta*ts_max) + 0.0001;
fprintf('The damping ratio zeta is %.4f\n', zeta);
fprintf('The natural frequency omega_n is %.4f\n', omega_n);

% find poles
P1 = -zeta*omega_n + 1i*omega_n*sqrt(1 - zeta^2);
P2 = -zeta*omega_n - 1i*omega_n*sqrt(1 - zeta^2);
fprintf('The poles of the system are:\n %.2f %.2fi\n %.2f %.2fi\n', real(P1), imag(P1), real(P2), imag(P2));

% use poles to find the desired KP and KD
Kd = (-a*(P1+P2)-b)/z;
Kp = (a*P1*P2-c)/z;
fprintf('The desired KP=%.2f, KD=%.2f\n', Kp, Kd);

% add pole for KI and update PID gains
% multiplier = 10;
% PI = -zeta*omega_n * multiplier;
multiplier = 0.5;
PI = multiplier*abs(P1);
fprintf('The pole for KI, PI=%.2f\n', PI);

% Kp_bar = real(Kp + a/z*PI*(P1+P2));
% Ki_bar = real(-PI*P1*P2*a/z);
% Kd_bar = real(Kd - a/z*PI);
Kp_bar = real(Kp + Kd*PI);
Ki_bar = real(Kp*PI);
Kd_bar = Kd;
fprintf('Final PID gains:\n KP=%.2f\n KI=%.2f\n KD=%.2f\n', Kp_bar, Ki_bar, Kd_bar);

%% e: reference tracking for closed loop system after running simulation
x_s = [pi/2; 0]; % sim init

fig = figure;
% hold on;
plot(out.tout, out.x1.data, 'b', 'LineWidth', 1.5, 'DisplayName', "$\theta$");
% plot(out.tout, out.r.data, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Reference');
ylabel("$\theta$ (rad)", 'Interpreter', 'latex');
yyaxis right;
plot(out.tout, out.v.data, 'r', 'LineWidth', 1, 'DisplayName', 'Voltage');
hold on;
% yline(9, 'm--', 'LineWidth', 1.5, 'DisplayName', 'Voltage Limit (+9V)');
% yline(-9, 'm--', 'LineWidth', 1.5, 'DisplayName', 'Voltage Limit (-9V)');
ylabel("Voltage (V)");
xlabel("Time (s)");
legend('Interpreter', 'latex');
title('HW3P2e Spotlight Reference Tracking with PID Controller');
fig.Position(3:4) = [1500 500];
saveas(fig, 'figs/hw3p2e', 'svg');

function xdot = pendulum_f(t, x, u)
% x = [theta, theta_dot]
% u = [V]
% system parameters
Rm = 3.5; % Ohms, Armature resistance
Kb = 0.1; % Vs/rad, Motor back EMF constant
Kt = 0.65*Kb; % Nm/A, Motor torque constant
% Lm;  H, Armature inductance; assume 0
mp = 0.04;% kg, Spotlight(pendulum) mass
Lp = 0.1; %m, Spotlight(pendulum) length
Ip = mp*(Lp)^2;% Moment of inertia of pendulum about center of mass
Bm = 0.000008; %Nms/rad (viscous friction coefficient)
g = 9.81; %m/s^2 acceleration due to gravity

x1_dot = x(2);
x2_dot = Kt*u/(Ip*Rm) - (Kt*Kb/Rm + Bm)*x(2)/Ip - mp*g*Lp*cos(x(1))/Ip;
xdot = [x1_dot; x2_dot];
end

function y = pendulum_h(t, x, u)
% x = [theta, theta_dot]
% u = [V]
y = x(1);
end

function A = pendulum_fdx(t, x, u)
% system parameters
Rm = 3.5; % Ohms, Armature resistance
Kb = 0.1; % Vs/rad, Motor back EMF constant
Kt = 0.65*Kb; % Nm/A, Motor torque constant
% Lm;  H, Armature inductance; assume 0
mp = 0.04;% kg, Spotlight(pendulum) mass
Lp = 0.1; %m, Spotlight(pendulum) length
Ip = mp*(Lp)^2;% Moment of inertia of pendulum about center of mass
Bm = 0.000008; %Nms/rad (viscous friction coefficient)
g = 9.81; %m/s^2 acceleration due to gravity

df1x1 = 0;
df1x2 = 1;
df2x1 = mp*g*Lp*sin(x(1))/Ip;
df2x2 = -(Kt*Kb/Rm + Bm)/Ip;
A = [df1x1 df1x2; df2x1 df2x2];
end

function xdot = pendulum_f_oc(t, x, u)
% x = [theta, theta_dot]
% u = [V]
% system parameters
% Rm = 3.5; % Ohms, Armature resistance
% Kb = 0.1; % Vs/rad, Motor back EMF constant
% Kt = 0.65*Kb; % Nm/A, Motor torque constant
% Lm;  H, Armature inductance; assume 0
mp = 0.04;% kg, Spotlight(pendulum) mass
Lp = 0.1; %m, Spotlight(pendulum) length
Ip = mp*(Lp)^2;% Moment of inertia of pendulum about center of mass
Bm = 0.000008; %Nms/rad (viscous friction coefficient)
g = 9.81; %m/s^2 acceleration due to gravity
x1_dot = x(2);
x2_dot = -Bm*x(2)/Ip - mp*g*Lp*cos(x(1))/Ip;
xdot = [x1_dot; x2_dot];
end

function plot_pend_states(t, x, title_str, ylim_1, ylim_2)
save_str = lower(strrep(title_str, ' ', '_'));
fig = figure;
sgtitle(title_str);

subplot(2, 1, 1);
plot(t, x(:, 1), "LineWidth", 1.5);
ylabel("$\theta$ (rad)", 'Interpreter', 'latex');
ylim(ylim_1);

subplot(2, 1, 2);
plot(t, x(:, 2), "LineWidth", 1.5);
ylabel("$\dot{\theta}$ (rad/s)", 'Interpreter', 'latex');
ylim(ylim_2);
xlabel("Time (s)");

saveas(fig, "figs/"+save_str, 'svg');
end

function plot_impulse_resp(t, y, title_str)
save_str = lower(strrep(title_str, ' ', '_'));
% wrap y to +-pi
% y = mod(y, 2*pi);
fig = figure;
if range(y) > 2*pi
	semilogy(t, y, "LineWidth", 1.5);
else
	plot(t, y, "LineWidth", 1.5);
end
title(title_str);
xlabel("Time (s)");
ylabel("Impulse response");
saveas(fig, "figs/"+save_str, 'svg');
end

