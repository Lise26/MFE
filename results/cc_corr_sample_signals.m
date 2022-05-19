clearvars; clc; close all;

%%%%%%%%%%%%%%%%%%%%%%%%%% SAMPLE SIGNALS %%%%%%%%%%%%%%%%%%%%%%%%%%
% Creation of sample signals
n = 250;
f=1/n;
t=0:f:2;

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
x4=rand(1,501);
y4=rand(1,501);

figure;
times = (0:500);
subplot(411)
plot(times,x1);
hold();
plot(times,y1);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('In phase signals');
subplot(412)
plot(times,x3);
hold();
plot(times,y3);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('Dephased signals');
subplot(413)
plot(times,x2);
hold();
plot(times,y2);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('Opposite-phase signals');
subplot(414)
plot(times,x4);
hold();
plot(times,y4);
xlabel('Time (s)');
ylabel('x(t), y(t)');
legend('x', 'y')
title('Random signals');
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

% Creation of a window containing the sample signals
wind = window(n, 0);
dat = horzcat(x1.',y1.',x2.',y2.',x3.',y3.',x4.',y4.');
wind.Data = dat;

%%%%%%%%%%%%%%%%%%%%%%%% CROSS-CORRELATION %%%%%%%%%%%%%%%%%%%%%%%%%
% Computation of the cross-correlation
cross = crossCorrelation();
cross_corr_dat1 = cross.measure(wind,1,2);
cross_corr_dat3 = cross.measure(wind,5,6);
cross_corr_dat2 = cross.measure(wind,3,4);
cross_corr_dat4 = cross.measure(wind,7,8);

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
cross_corr_dat1 = cross.FTmeasure(wind,1,2);
cross_corr_dat3 = cross.FTmeasure(wind,5,6);
cross_corr_dat2 = cross.FTmeasure(wind,3,4);
cross_corr_dat4 = cross.FTmeasure(wind,7,8);

lag = -cross.Max_lag:cross.Max_lag;
figure;
subplot(411)
plot(lag, cross_corr_dat1)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for in-phase signals')
subplot(412)
plot(lag, cross_corr_dat3)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for dephased signals')
subplot(413)
plot(lag, cross_corr_dat2)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for opposite-phase signals')
subplot(414)
plot(lag, cross_corr_dat4)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the cross-correlation for random signals')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])

%%%%%%%%%%%%%%%%%%% CORRECTED CROSS-CORRELATION %%%%%%%%%%%%%%%%%%%%

% Computation of the corrected cross-correlation
corr = correctedCrossCorrelation();
corr_cross_corr_dat1 = corr.measure(wind,1,2);
corr_cross_corr_dat2 = corr.measure(wind,3,4);
corr_cross_corr_dat3 = corr.measure(wind,5,6);
corr_cross_corr_dat4 = corr.measure(wind,7,8);

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

% Computation of the Fisher Transform of the corrected cross-correlation
cross_corr_dat1 = corr.FTmeasure(wind,1,2);
cross_corr_dat2 = corr.FTmeasure(wind,3,4);
cross_corr_dat3 = corr.FTmeasure(wind,5,6);
cross_corr_dat4 = corr.FTmeasure(wind,7,8);

lag = 1:cross.Max_lag;
figure;
subplot(411)
plot(lag, cross_corr_dat1)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the corrected cross-correlation for in-phase signals')
subplot(412)
plot(lag, cross_corr_dat3)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the corrected cross-correlation for dephased signals')
subplot(413)
plot(lag, cross_corr_dat2)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the corrected cross-correlation for opposite-phase signals')
subplot(414)
plot(lag, cross_corr_dat4)
ylabel('Fisher Transform'); xlabel('Lag (s)')
title('Fisher Transform of the corrected cross-correlation for random signals')
set(gcf, 'units','normalized','outerposition',[0 0 1 1])