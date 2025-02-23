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


%Optimization weights
Q =diag([10 1e-2 10 1e-2]);
rho = 1;

Ts = 0.01; %Sampling time
N = 50; % Horizon


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
    u = MPCCtrl(x,road_profile);
    uMPC(j) = u;

    % Feed input to simulator
    [x,road_profile]= activeSuspSim (x,u,s,N,totalTime);
    xMPC(:,j+1) = x;
    
    % Increase position by a step
    s = j/10;
end

%Plots
k = (0:L)*Ts; % ...in seconds

figure(1);

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

%% Simulate LQR and Active Suspension Turned Off
% Initialization
% LQR
xLQR = zeros(n,L+1);
uLQR = zeros(1,L);

%Passive Suspension (No Control)
xNC = zeros(n,L+1);
uNC = zeros(1,L);

% Initial x
x = xLQR(:,1); 
xnc = xNC(:,1);

s = 0; % Initial s

for j = 1:L

    % LQR Control
    u = LQRCtrl(x);
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


figure(2);

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
legend ('Body acc, MPC','Body acc, LQR', 'Body acc, Passive', 'Location','southeast'); grid on

%%
function u = MPCCtrl(x,d_traj)
% Incorrect MPC function
% Input:x and road profile
% Output: MPC input

u = -(x(1) + d_traj'*d_traj);

end

function u = LQRCtrl(x)
% Incorrect LQR function
% Input:x 
% Output: LQR control input

u = - x(1);

end