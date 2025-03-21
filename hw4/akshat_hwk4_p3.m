%% ME599 HW4 Problem 2
clc; clear; close all;

S = 1:6; % states
gamma = 0.8; % discount factor

% Rewards in the example problem
R = [ % rewards
	-1 -1 -1 -1 0 -1;
	-1 -1 -1 0 -1 100;
	-1 -1 -1 0 -1 -1;
	-1 0 0 -1 0 -1;
	0 -1 -1 0 -1 100;
	-1 0 -1 -1 0 100;
	];

[Q, policy] = Q_learning(S, R, gamma);
disp('Optimal Q-table:');
disp(Q);
disp('Optimal policy:');
disp(policy);

%% part a
R = [ % rewards
	-1 -1 -1 -1 0 -1;
	-1 -1 -1 0 -1 1;
	-1 -1 -1 0 -1 -1;
	-1 0 0 -1 0 -1;
	0 -1 -1 0 -1 1;
	-1 0 -1 -1 0 1;
	];

[Q_a, policy_a] = Q_learning(S, R, gamma);

disp('Optimal Q-table (part a):');
disp(Q_a);
disp('Optimal policy (part a):');
disp(policy_a);

% part b
R = [ % rewards
	-1 -1 -1 -1 0 -1;
	-1 -1 -1 0 -1 1;
	-1 -1 -1 0 -1 -1;
	-1 0 0 -1 0 -1;
	0 -1 -1 0 -1 -0.9;
	-1 0 -1 -1 0 1;
	];

[Q_b1, policy_b1] = Q_learning(S, R, gamma);
disp('Optimal Q-table (part b1):');
disp(Q_b1);
disp('Optimal policy (part b1):');
disp(policy_b1);

% part c
R = [ % rewards
	-1 -1 -1 -1 0 -1;
	-1 -1 -1 0 -1 1;
	-1 -1 -1 0 -1 -1;
	-1 0 0 -1 0 -1;
	0 -1 -1 0 -1 -0.5;
	-1 0 -1 -1 0 1;
	];

[Q_b2, policy_b2] = Q_learning(S, R, gamma);
disp('Optimal Q-table (part b2):');
disp(Q_b2);
disp('Optimal policy (part b2):');
disp(policy_b2);

function [Q, policy] = Q_learning(S, R, gamma)
Q = zeros(6, 6); % Q-table
tmax = 2000; % max number of iterations

% step 1: initialize
t = 1; % iteration counter
% DO NOT USE randsample(S,1) to select initial state
% https://www.mathworks.com/help/stats/randsample.html#d126e992298
x_k = datasample(S, 1); % initial state, pick randomly

while true
	% step 2: get action and reward
	% u_k = randsample(S,1); % select action randomly
	u_k = datasample(S(R(x_k, :) ~= -1), 1); % select action randomly from valid actions
	x_kp1 = u_k; % next state
	c_k = R(x_k, u_k); % reward
	t = t+1; % increment iteration counter
	
	% step 3: update Q-table
	Q(x_k, u_k) = c_k + gamma * max(Q(x_kp1, :));
	
	% step 4: check for max iterations
	if t > tmax
		break;
	else
		x_k = x_kp1; % update state
	end
end

% step 5: find optimal policy
[~, policy] = max(Q, [], 2); % find action with max Q-value for each state
policy = policy - 1; % convert to 0-indexed
end
