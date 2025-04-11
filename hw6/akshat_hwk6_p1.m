%% ME599 HW6 Problem 1

clc; clear; close all;

load('freq_resp_data.mat');

%% loop through m and n and check least squares error
max_order = 6;
errs = ones(max_order, max_order)*Inf;
for n=1:max_order
	for m=1:n
		[theta, A, b] = freqSysId(m, n, W, PHASE_RAD_M, MAG_M);
		errs(m, n) = norm(A*theta - b);
	end
end

fprintf("%s\n", formattedDisplayText(errs,"NumericFormat","shortEng"));

m = 2; n = 3; % best from experiment
[theta, A, b] = freqSysId(m, n, W, PHASE_RAD_M, MAG_M);
fprintf('HW6 P1d: Approximate system transfer function:\n');
model = getModelFromTheta(m, theta)

% plot
% bode_opts = bodeoptions;
% bode_opts.Title.String = 'HW6 P1d: Bode plot of the approximated system';
% bode_opts.Title.FontSize = 14;
[mags, phases, freqs] = bode(model, W);
mags = squeeze(mags); phases = squeeze(phases);
% NOTE: saving doesnt work, go to the plot and save it manually

fig = figure;
sgtitle('HW6 P1d: Bode plot of the approximated system');

subplot(2, 1, 1)
semilogx(freqs, db(mags), 'b', 'LineWidth', 2, 'DisplayName', 'Approximate system')
hold on;
semilogx(W, db(MAG_M), 'r--', 'LineWidth', 2, 'DisplayName', 'Data')
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
ylim([-60 0]);
legend('Location', 'best');
grid on; grid minor;

subplot(2, 1, 2)
semilogx(freqs, phases, 'b', 'LineWidth', 2, 'DisplayName', 'Approximate system')
hold on;
semilogx(W, rad2deg(PHASE_RAD_M), 'r--', 'LineWidth', 2, 'DisplayName', 'Data')
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
ylim([-360 -90]);
legend('Location', 'best');
grid on; grid minor;

fig.Position(3:4) = [800 600];
saveas(fig, 'figs/hw6p1d_bode.svg');

function [theta, A, b] = freqSysId(m, n, freqs, phase, mag)
num_freqs = size(freqs, 1);

% construct A, b
% rows: 2*k, one for real and one for imaginary part
% columns: a=0->n-1, b=0->m, so n+m+1
A = zeros(num_freqs *2, m+n+1);
b = zeros(num_freqs *2, 1);
for k=1:num_freqs
	[GR, GI] = pol2cart(phase(k), mag(k));
	GI = 1j*GI;
	w = freqs(k);
	row_re = zeros(1, size(A, 2));
	row_im = zeros(1, size(A, 2));
	for p=0:n-1 % for a coefficients
		jw_p = (1j * w)^p;
		if isreal(jw_p)
			row_re(p+1) = -real(jw_p * GR);
			row_im(p+1) = -imag(jw_p * GI);
		else
			row_re(p+1) = -real(jw_p * GI);
			row_im(p+1) = -imag(jw_p * GR);
		end
	end
	for p=0:m % for b coefficients
		jw_p = (1j * w)^p;
		if isreal(jw_p)
			row_re(n+p+1) = real(jw_p);
		else
			row_im(n+p+1) = imag(jw_p);
		end
	end
	idx = (k-1)*2 + 1; % index for real part
	A(idx, :) = row_re;
	A(idx+1, :) = row_im;
	
	% construct b
	jw_n = (1j * w)^n;
	if isreal(jw_n)
		b(idx) = real(jw_n * GR);
		b(idx+1) = imag(jw_n * GI);
	else
		b(idx) = real(jw_n * GI);
		b(idx+1) = imag(jw_n * GR);
	end
end

% find theta
theta = A\b;
end

function model = getModelFromTheta(m, theta)
% tf needs higher orders first, so enumerate backwards
theta = flip(theta);
numerator = theta(1:m+1)'; % for b's
denominator = [1, theta(m++2:end)']; % for a's, add 1 as highest order coefficient
model = tf(numerator, denominator);
end