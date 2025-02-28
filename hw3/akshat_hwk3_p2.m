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

% part b equilibrium points and stability
x1_eq1 = pi/2;
x1_eq2 = 3*pi/2;
x2_eq = 0;
u_eq = 0;

A = pendulum_fdx(0, [x1_eq1; x2_eq], u_eq);
A2 = pendulum_fdx(0, [x1_eq2; x2_eq], u_eq);

e = eig(A);
e2 = eig(A2);

fprintf('The eigenvalues of the linearized system about the equilibrium point x1=pi/2 are:\n %.2f\n %.2f\n', e(1), e(2));
fprintf('The eigenvalues of the linearized system about the equilibrium point x1=3pi/2 are:\n %.2f\n %.2f\n', e2(1), e2(2));

% check stability
if real(e(1)) < 0 && real(e(2)) < 0
	fprintf('The equilibrium point x1=pi/2 is stable\n');
else
	fprintf('The equilibrium point x1=pi/2 is unstable\n');
end

if real(e2(1)) < 0 && real(e2(2)) < 0
	fprintf('The equilibrium point x1=3pi/2 is stable\n');
else
	fprintf('The equilibrium point x1=3pi/2 is unstable\n');
end

% perturb system
p = [0.01; 0.01]; % perturbation
u0 = u_eq;
x0 = [x1_eq1; x2_eq] + p;
[t, x] = ode45(@(t, x) pendulum_f(t, x, u0), [0 10], x0);
plot_pend_states(t, x, 'HW3P2b Closed circuit dynamics (xeq1)', [0 8], [-20 20]);
[t, x] = ode45(@(t, x) pendulum_f_oc(t, x, u0), [0 10], x0);
plot_pend_states(t, x, 'HW3P2b Open circuit dynamics (xeq1)', [0 8], [-20 20]);

x0 = [x1_eq2; x2_eq] + p;
[t, x] = ode45(@(t, x) pendulum_f(t, x, u0), [0 10], x0);
plot_pend_states(t, x, 'HW3P2b Closed circuit dynamics (xeq2)', [4.7 4.725], [-0.1 0.1]);
[t, x] = ode45(@(t, x) pendulum_f_oc(t, x, u0), [0 10], x0);
plot_pend_states(t, x, 'HW3P2b Open circuit dynamics (xeq2)', [4.7 4.725], [-0.1 0.1]);


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

saveas(fig, save_str, 'svg');
end


