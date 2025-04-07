%% ME599 HW6 Problem 1

clc; clear; close all;

load('freq_resp_data.mat');

%%
num_freqs = size(W, 1);
% order of the system, keep it even
m = 1;
n = 2;
assert(mod(n, 2) == 0, 'n and m must be even');

% construct A, b
% rows: 2*k, one for real and one for imaginary part
% columns: a=0->n-1, b=0->m, so n+m+1
A = zeros(num_freqs *2, m+n+1);
b = zeros(num_freqs *2, 1);
for k=1:num_freqs
	[GR, GI] = pol2cart(PHASE_RAD_M(k), MAG_M(k));
	GI = 1j*GI;
	w = W(k);
	row_re = zeros(1, size(A, 2));
	row_im = zeros(1, size(A, 2));
	for p=0:n-1 % for a
		jw_p = (1j * w)^p;
		if isreal(jw_p)
			row_re(p+1) = -real(jw_p * GR);
			row_im(p+1) = -imag(jw_p * GI);
		else
			row_re(p+1) = -real(jw_p * GI);
			row_im(p+1) = -imag(jw_p * GR);
		end
	end
	for p=0:m % for b
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
	% assumes n is even
	b(idx) = real((1j * w)^n * GR);
	b(idx+1) = imag((1j * w)^n * GI);
end

% find theta
theta = A\b;
% tf needs higher orders first, so enumerate backwards
theta = flip(theta);
numerator = theta(1:m+1)'; % for b's
denominator = [1, theta(m++2:end)']; % for a's, add 1 as highest order coefficient
fprintf('HW6 P1d: Approximate system transfer function:\n');
model = tf(numerator, denominator)

% plot
bode_opts = bodeoptions;
bode_opts.Title.String = 'HW6 P1d: Bode plot of the approximated system';
bode_opts.Title.FontSize = 14;
bp = bodeplot(model, W, bode_opts);
% NOTE: saving doesnt work, go to the plot and save it manually
