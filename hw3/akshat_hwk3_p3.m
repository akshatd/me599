%% ME599 HW3 Problem 3
clc; clear; close all;

% Physical parameters
mb = 300;    % kg
mw = 60;     % kg
bs = 1000;   % N/m/s
ks = 16000 ; % N/m
kt = 190000; % N/m

% Continuous-time State matrices
Ac = [ 0 1 0 0; [-ks -bs ks bs]/mb ; ...
    0 0 0 1; [ks bs -ks-kt -bs]/mw];
Bc = [ 0 0; 0 10000/mb ; 0 0 ; [kt -10000]/mw];
Cc = [1 0 0 0; 1 0 -1 0; Ac(2,:)];
Dc = [0 0; 0 0; Bc(2,:)];

Ts = 0.01; % Sampling time

% Discretize the system
[Ad, B, Cd, Dd] = c2dm(Ac, Bc, Cc, Dc, 0.01, 'zoh');
E = B(:,1);
Bd = B(:,2);

% Optimization weights
Q =diag([10 1e-2 10 1e-2]);
rho = 1;

N = 50; % Horizon

% precompute matrices
[A_bar, B_bar, E_bar, Q_bar, R_bar] = MPCMatrices(Ad,Bd,E,Q,rho,N);

% Initialization
totalTime = 3; %Simulation Time
L = totalTime/Ts; % Intervals based on sampling time

n = size(Ac,2);
xMPC = zeros(n,L+1); % For storing x
uMPC = zeros(1,L); % For storing u

x = xMPC(:,1); % Initial x
s = 0; % Initial s
u = 0; [~,road_profile]= activeSuspSim (x,u,s,N,totalTime); %inital disturbance profile

% Simulation
for j = 1:L
    
    %MPC Input
    u = MPCCtrl(x, road_profile, A_bar, B_bar, E_bar, Q_bar, R_bar);
    uMPC(j) = u;
    
    % Feed input to simulator
    [x,road_profile]= activeSuspSim (x,u,s,N,totalTime);
    xMPC(:,j+1) = x;
    
    % Increase position by a step
    s = j/10;
end

%Plots
k = (0:L)*Ts; % ...in seconds

fig = figure(1);
sgtitle('HW3 P3a: MPC Control')

subplot(3,1,1)
plot(k,xMPC(1,:),'-',k, xMPC(3,:),'-.','LineWidth',1.5);
xlabel('Time (s)');ylabel('Travel (m)');
legend ('Body travel, x_1','Wheel travel, x_3')
title ('Body and Wheel Travel')

subplot(3,1,2);
plot(k,xMPC(2,:),'-',k,xMPC(4,:),'-.','LineWidth',1.5);
xlabel('Time (s)'),ylabel('Vel (m/s)');
legend ('Body vel, x_2','Wheel vel, x_4')
title ('Body and Wheel Velocity')

subplot(3,1,3)
plot(k(1:end-1),uMPC,'LineWidth',1.5);
title('Control force')
xlabel('Time (s)'), ylabel('f_s (kN)');

fig.Position(3:4) = [800 800];
saveas(fig,'figs/hw3p3a.svg');
%% Simulate LQR and Active Suspension Turned Off
% Initialization
% LQR
xLQR = zeros(n,L+1);
uLQR = zeros(1,L);

% compute K_opt
[K_opt,~,~] = dlqr(Ad,Bd,Q,rho);

%Passive Suspension (No Control)
xNC = zeros(n,L+1);
uNC = zeros(1,L);

% Initial x
x = xLQR(:,1);
xnc = xNC(:,1);

s = 0; % Initial s

for j = 1:L
    
    % LQR Control
    u = LQRCtrl(x, K_opt);
    uLQR(j) = u;
    x= activeSuspSim (x,u,s,N,totalTime);
    xLQR(:,j+1) = x;
    
    %No control
    xnc= activeSuspSim (xnc,0,s,N,totalTime);
    xNC(:,j+1) = xnc;
    
    % Increase position by a step
    s = j/10;
end

% Compute Body acceleration
%MPC
yMPC = Cc*xMPC(:,1:end-1) + Dc(:,2)*uMPC; % Output
abMPC = yMPC(3,:); % Body acceleration

% LQR
yLQR = Cc*xLQR(:,1:end-1) + Dc(:,2)*uLQR; % Output
abLQR = yLQR(3,:);% Body acceleration

% NC
yNC = Cc*xNC(:,1:end-1) + Dc(:,2)*uNC; % Output
abNC = yNC(3,:);% Body acceleration


fig = figure(2);
sgtitle('HW3 P3b: MPC, LQR and Passive Control Comparison');

subplot(4,1,1);
plot(k,xMPC(1,:),'-',k,xLQR(1,:),'-.',k,xNC(1,:),'--','LineWidth',1.5);
xlabel('time step, k'),ylabel('Travel (m)');
legend ('Body travel, MPC','Body travel, LQR', 'Body travel, Passive')
title ('Body Travel Comparison')
% You are to add a plot of the Road Profile to this subplot

subplot(4,1,2);
plot(k,xMPC(2,:),'-',k,xLQR(2,:),'-.',k,xNC(2,:),'--','LineWidth',1.5);
xlabel('time step, k'),ylabel('Vel (m/s)');
legend ('Body vel, MPC','Body vel, LQR', 'Body vel, Passive')
title ('Body Velocity Comparison')

subplot(4,1,3)
plot(k(1:end-1),abMPC,'-',k(1:end-1),abLQR,'-.',k(1:end-1),abNC,'--','LineWidth',1.5);
title('Body Acceleration Comparison')
xlabel('time step, k'), ylabel('a_b (m/s^2)')
legend ('Body acc, MPC','Body acc, LQR', 'Body acc, Passive', 'Location','southeast');

subplot(4,1,4)
plot(k(1:end-1),uMPC,k(1:end-1),uLQR,k(1:end-1),uNC,'--','LineWidth',1.5);
title('Control force')
xlabel('time step, k'), ylabel('f_s (kN)');
legend ('Control force, MPC','Control force, LQR', 'Control force, Passive', 'Location','southeast'); grid on

fig.Position(3:4) = [800 800];
saveas(fig,'figs/hw3p3b.svg');
%%
function u = MPCCtrl(x,d_traj, A_bar, B_bar, E_bar, Q_bar, R_bar)
% Input:x and road profile
% Output: MPC input

% u = -(x(1) + d_traj'*d_traj);
F_k = A_bar*x + E_bar*d_traj;
U_k = -inv(B_bar'*Q_bar*B_bar + R_bar)*B_bar'*Q_bar*F_k;

% take first control input
u = U_k(1);

end

function u = LQRCtrl(x, K_opt)
% Input:x
% Output: LQR control input

% u = - x(1);
u = -K_opt*x;

end

function [A_bar, B_bar, E_bar, Q_bar, R_bar] = MPCMatrices(A,B,E,Q,R,N)
nx = size(A,2);
nu = size(B,2);
nd = size(E,2);

% initialize matrices
A_bar = zeros(N*nx,nx);
B_bar = zeros(N*nx,N*nu);
E_bar = zeros(N*nx,N*nd);
Q_bar = zeros(N*nx,N*nx);
R_bar = zeros(N*nu,N*nu);

% Compute first row of A_bar then use it to initialize the rest
A_bar(1:nx,:) = A;
for i = 2:N
    A_bar((i-1)*nx+1 : i*nx, :) = A_bar((i-2)*nx+1:(i-1)*nx,:)*A;
end

% Compute first column of B_bar then use it to initialize the rest
for i = 1:N
    B_bar((i-1)*nx+1 : i*nx, 1:nu) = A^(i-1)*B;
end
for i = 2:N
    zero_rows = (i-1)*nx;
    zero_cols = nu;
    B_bar(:, (i-1)*nu+1 : i*nu) = [zeros(zero_rows,zero_cols); B_bar(1:end-zero_rows, 1:nu)];
end

% Compute first column of E_bar then use it to initialize the rest
for i = 1:N
    E_bar((i-1)*nx+1 : i*nx, 1:nd) = A^(i-1)*E;
end
for i = 2:N
    zero_rows = (i-1)*nx;
    zero_cols = nd;
    E_bar(:, (i-1)*nd+1 : i*nd) = [zeros(zero_rows,zero_cols); E_bar(1:end-zero_rows, 1:nd)];
end

% Compute Q_bar
for i = 1:N
    Q_bar((i-1)*nx+1 : i*nx, (i-1)*nx+1 : i*nx) = Q;
end

% Compute R_bar
for i = 1:N
    R_bar((i-1)*nu+1 : i*nu, (i-1)*nu+1 : i*nu) = R;
end

end