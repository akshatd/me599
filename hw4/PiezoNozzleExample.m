load('V_example');
N = 200; % simulation duration (in number of time steps) each step is 0.1\mu s
P = piezo_nozzle(V_example,N); % Simulate pressure evolution

% Plot 
figure; time = 0.1*(1:N);
yyaxis left; plot(time,P(1:N),'LineWidth',1.5); ylabel('$P(kPa)$','Interpreter','latex')
yyaxis right; plot(time,V_example(1:N),'--','LineWidth',1.5);ylim([-30 45]);
ylabel('$V(V)$','Interpreter','latex')
xlabel('$t(\mu s)$','Interpreter','latex')