%n,m - state and input dimensions, respectively
n=12; m=4;

%Random initial state
xi=10*rand(n,1)-5;

%Random input
u=10*rand(m,1)-5;

Ts = 0.1;  % Time step

% State Ts time after
xi = aerialVehSim(xi,u,Ts);
