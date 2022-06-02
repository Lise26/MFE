% Code to generate illustrations of the association measures on sample
% vectors - CHAPTER: METHOD

clearvars; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%% SAMPLE SIGNALS %%%%%%%%%%%%%%%%%%%%%%%%%%
Fs = 250;
Ts = 1/Fs;
L = 500;
t = (0:L-1)*Ts;

% For the cross-correlation & corrected version
% In phase
x1=sin(2*pi*10*t);
y1=sin(2*pi*10*t);
% Out of phase
x3=sin(2*pi*10*t+20);
y3=sin(2*pi*10*t);
% Opposite phase
x2=sin(-2*pi*10*t);
y2=sin(2*pi*10*t);
% Random
x4=rand(1,500);
y4=rand(1,500);

% Display of the sample signals
figure;
subplot(411)
plot(t,x1);
hold();
plot(t,y1);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('In phase signals');
subplot(412)
plot(t,x3);
hold();
plot(t,y3);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('Dephased signals');
subplot(413)
plot(t,x2);
hold();
plot(t,y2);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('Opposite-phase signals');
subplot(414)
plot(t,x4);
hold();
plot(t,y4);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('Random signals');
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

% For the wPLI
% Fixed phase difference between the two signals
L = 7500;
t = (0:L-1)*Ts;
phi_t = pi():-pi()/100:-pi();
x = cos(2*pi*30*t); 
y(:,:) = cos(2*pi*30*t+phi_t(:));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WINDOWS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creation of a windows to compute the association measures
wind = window(Fs, 0);


%%%%%%%%%%%%%%%%%%%%%%%% CROSS-CORRELATION %%%%%%%%%%%%%%%%%%%%%%%%%
cross = crossCorrelation();
cross_corr_dat1 = cross.association(wind,x1,y1);
cross_corr_dat2 = cross.association(wind,x2,y2);
cross_corr_dat3 = cross.association(wind,x3,y3);
cross_corr_dat4 = cross.association(wind,x4,y4);

lag = -cross.Max_lag:cross.Max_lag;
figure;
subplot(411)
plot(lag, cross_corr_dat1.Value)
ylabel('Cross-correlation'); xlabel('Lag (s)')
title('Cross-correlation of in-phase signals')
subplot(412)
plot(lag, cross_corr_dat3.Value)
ylabel('Cross-correlation'); xlabel('Lag (s)')
title('Cross-correlation of dephased signals')
subplot(413)
plot(lag, cross_corr_dat2.Value)
ylabel('Cross-correlation'); xlabel('Lag (s)')
title('Cross-correlation of opposite-phase signals')
subplot(414)
plot(lag, cross_corr_dat4.Value)
ylabel('Cross-correlation'); xlabel('Lag (s)')
title('Cross-correlation of random signals')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

% Computation of the Fisher Transform of the cross-correlation
cross_corr_dat1 = cross.FTmeasure(wind,x1,y1);
cross_corr_dat2 = cross.FTmeasure(wind,x2,y2);
cross_corr_dat3 = cross.FTmeasure(wind,x3,y3);
cross_corr_dat4 = cross.FTmeasure(wind,x4,y4);

figure;
subplot(411)
plot(lag, real(cross_corr_dat1))
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for in-phase signals')
subplot(412)
plot(lag, cross_corr_dat3)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for dephased signals')
subplot(413)
plot(lag, real(cross_corr_dat2))
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for opposite-phase signals')
subplot(414)
plot(lag, cross_corr_dat4)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for random signals')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])


%%%%%%%%%%%%%%%%%%% CORRECTED CROSS-CORRELATION %%%%%%%%%%%%%%%%%%%%
corr = correctedCrossCorrelation();
corr_cross_corr_dat1 = corr.association(wind,x1,y1);
corr_cross_corr_dat2 = corr.association(wind,x2,y2);
corr_cross_corr_dat3 = corr.association(wind,x3,y3);
corr_cross_corr_dat4 = corr.association(wind,x4,y4);

lag = 1:cross.Max_lag;
figure;
subplot(411)
plot(lag, corr_cross_corr_dat1.Value)
ylabel('Corected cross-correlation'); xlabel('Lag (s)')
title('Corrected cross-correlation of in-phase signals')
subplot(412)
plot(lag, corr_cross_corr_dat3.Value)
ylabel('Corrected cross-correlation'); xlabel('Lag (s)')
title('Corrected cross-correlation of dephased signals')
subplot(413)
plot(lag, corr_cross_corr_dat2.Value)
ylabel('Corrected cross-correlation'); xlabel('Lag (s)')
title('Corrected cross-correlation of opposite-phase signals')
subplot(414)
plot(lag, corr_cross_corr_dat4.Value)
ylabel('Corrected cross-correlation'); xlabel('Lag (s)')
title('Corrected cross-correlation of random signals')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% WPLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wpli = wPLI();
wpli.Num_window = floor(length(x)/(wind.Length-wind.Overlap)) - 1;
res = zeros(5,length(phi_t)); 
for p=1:length(phi_t)
    res(:,p) = wpli.measure(wind, x.', y(p,:).');
end

phi_t=-phi_t ; 
phi = {'-\pi','-3\pi/4','-\pi/2','-\pi/4','0','\pi/4','\pi/2','3\pi/4','\pi'};
figure; 
plot(phi_t,squeeze(res(4,:)),'-blue','LineWidth',1.5);
set(gca,'xlim',[-pi() pi()],'xtick',-pi():pi()/4:pi(),'xticklabel', phi); 
title('wPLI of sample signals for different fixed phase differences');
set(gcf, 'units','normalized','outerposition',[0 0 1 1])