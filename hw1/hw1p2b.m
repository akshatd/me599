%% ME599 HW1 Problem 2b

clc; clear; close all;

%% load data
load('hwk1_p2b.mat');

%% recover image

blur = 1/100 * [...
	0 2 4 2 0;
	2 4 6 4 2;
	4 6 8 6 4;
	2 4 6 4 2;
	0 2 4 2 0
	];

Xblurred_fft = fft2(Xblurred);
blur_fft = fft2(blur, size(Xblurred, 1), size(Xblurred, 2)); % pad the blur kernel to the size of the image

X_fft = Xblurred_fft ./ blur_fft;
X = ifft2(X_fft);

%% plot
figure;
sgtitle('HW1 P2b: Blurred and Recovered Image');

subplot(1, 2, 1);
imshow(uint8(Xblurred));
title('Blurred Image');
axis image;

subplot(1, 2, 2);
imshow(uint8(X));
title('Recovered Image');
axis image;
