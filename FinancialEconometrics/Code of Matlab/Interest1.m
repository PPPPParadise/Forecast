% load the data of interest of 10-year-maturity and 1-year-maturity interest
% rate data for the period of January 1960 to December 2017.

clear;
clc;
load IRdata;

% plot the two time-series data analysis

figure(1)
subplot(2,1,1)
plot(interest1y)
subplot(2,1,2)
plot(interest10y)

% check the acf and pacf of the two time series to determine p and q

figure(2)
subplot(2,2,1)
autocorr(interest1y)
subplot(2,2,2)
parcorr(interest1y)
subplot(2,2,3)
autocorr(interest10y)
subplot(2,2,4)
parcorr(interest10y)

% both of the acf shows they are not stationary so wo do the first-order
% difference

IR1y = diff(interest1y);
IR10y = diff(interest10y);
figure(3)
subplot(2,2,1)
autocorr(IR1y)
subplot(2,2,2)
parcorr(IR1y)
subplot(2,2,3)
autocorr(IR10y)
subplot(2,2,4)
parcorr(IR10y)

% Comments: According to the acf and pacf it is not very clear to choose which model
% We may try AR(1),MA(1),ARMA(1,1),AR(2),MA(2),ARMA(2,1),ARMA(1,2),ARMA(2,2) 
% (actually none of them perform well,I even tried the twelve-order difference also not 
% perform well). But according to the requirements we will try AR(1)
% MA£¨1£©ARMA£¨1,1) to compare using 1-year interest rate

Mdl1y1 = arima('ARlags',1);
[EstMdl1y1,~,log1yL1] = estimate(Mdl1y1,IR1y);
Mdl1y2 = arima('MAlags',1);
[EstMdl1y2,~,log1yL2] = estimate(Mdl1y2,IR1y);
Mdl1y3 = arima('ARlags',1,'MAlags',1);
[EstMdl1y3,~,log1yL3] = estimate(Mdl1y3,IR1y);

% Similarly do the estimate model in 10-year interest rate.

Mdl10y1 = arima('ARlags',1);
[EstMdl10y1,~,log10yL1] = estimate(Mdl10y1,IR10y);
Mdl10y2 = arima('MAlags',1);
[EstMdl10y2,~,log10yL2] = estimate(Mdl10y2,IR10y);
Mdl10y3 = arima('ARlags',1,'MAlags',1);
[EstMdl10y3,~,log10yL3] = estimate(Mdl10y3,IR10y);

%% Compare these three TS models using likelihood ratio test for 1-year
% compare TS1 with TS3

[h1,pValue1] = lratiotest(log1yL3,log1yL1,1);

% We need to reject the null hypothesis so the unrestricted model ARMA£¨1£¬1£©
% performs better

% compare TS2 with TS3

[h2,pValue2] = lratiotest(log1yL3,log1yL2,1);

% We need to reject the null hypothesis so the unrestricted model ARMA£¨1£¬1£©
% performs better

% Actuall we don't need to compare the TS1 and TS2 since TS3 performs better

[aicTS1,bicTS1] = aicbic(log1yL1,5,size(IR1y,1));
[aicTS2,bicTS2] = aicbic(log1yL2,5,size(IR1y,1));

% display the results

display([h1,pValue1;h2,pValue2;aicTS1,bicTS1;aicTS2,bicTS2]);


%% Similarly compare these three TS models using likelihood ratio test for 10-year
% compare TS1 with TS3

[h10,pValue10] = lratiotest(log10yL3,log10yL1,1);

% We need to reject the null hypothesis so the unrestricted model ARMA£¨1£¬1£©
% performs better

% compare TS2 with TS3

[h20,pValue20] = lratiotest(log10yL3,log10yL2,1);

% We need to reject the null hypothesis so the unrestricted model ARMA£¨1£¬1£©
% performs better

% Actuall we don't need to compare the TS1 and TS2 since TS3 performs better

[aicTS10,bicTS10] = aicbic(log10yL1,5,size(IR10y,1));
[aicTS20,bicTS20] = aicbic(log10yL2,5,size(IR10y,1));

% Display the results

display([h10,pValue10;h20,pValue20;aicTS10,bicTS10;aicTS20,bicTS20]);

%% So the conclusion is that both for the 1-year or 10-year interest rate
% the ARMA(1,1) performs better
