%% ME599 HW1 Problem 2a

clc; clear; close all;

%% load data

load('hwk1_p2a.mat');
% sound(piano_noisy, Fs);

%% analyze

% do fft
n = length(piano_noisy);
piano_noisy_fft = fft(piano_noisy, n);
piano_noisy_psd = piano_noisy_fft.*conj(piano_noisy_fft)/n;

% find piano freq band
indices_clean = false(n,1);
indices_clean(1:70000) = true;

indices_noise = ~indices_clean;
noise_fft = piano_noisy_fft.*indices_noise;
noise_psd = noise_fft.*conj(noise_fft)/n;
anti_noise = -ifft(noise_fft, 'symmetric');
save('anti_noise.mat', 'anti_noise');

piano_unnoised = piano_noisy + anti_noise;

figure;
subplot(2,1,1);
plot(piano_noisy_psd(1:n/2)); % plot first half, second half is a mirror
title('PSD of noisy piano');
xlabel('Frequency (Hz)');
ylabel('Power');
subplot(2,1,2);
plot(noise_psd(1:n/2));
title('PSD of noise');
xlabel('Frequency (Hz)');
ylabel('Power');

%% listen
% sound(noise, Fs);
sound(piano_unnoised, Fs);