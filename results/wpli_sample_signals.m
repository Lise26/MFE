clearvars; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%% SAMPLE SIGNALS %%%%%%%%%%%%%%%%%%%%%%%%%%
% Creation of sample signals
Fs = 250;                   
Ts = 1/Fs;                   
L=7500; %~30sec => 900 cycles
t = (0:L-1)*Ts; 

% fixed phase difference between the two signals
phi_t = [pi():-pi()/100:-pi()];
x = cos(2*pi*30*t); 
y(:,:) = cos(2*pi*30*t+phi_t(:));

% Creation of a window containing the sample signals
wind = window(Fs, 0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WPLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

measure = wPLI();
res = zeros(5,length(phi_t)); 
for p=1:length(phi_t)
    res(:,p) = measure.measure(wind, x, y(p,:));
end

phi_t=-phi_t ; 
figure('Name','wpli') ; 
plot(phi_t,squeeze(res(4,:)),'-blue','LineWidth',1.5);
set(gca,'xlim',[-pi() pi()],'xtick',[-pi():pi()/4:pi()],'xticklabel', ...
 {'-\pi' '-3\pi/4' '-\pi/2' '-\pi/4' '0' '\pi/4' '\pi/2' '3\pi/4' '\pi'}); 
title('wpli');