% Modeling longtime interest rate

clear;
clc;
load IRdata

%% Preliminary data analysis

figure(1) %plot two time series of interest
plot([interest1y,interest10y])


%% step 1: using OLS to estimate Model 2:dy=alpha +beta*dx +e

IR10y = diff(interest10y);
IR1y = diff(interest1y);
EstMdl1 = fitlm(IR10y,IR1y);
disp(EstMdl1)
ehat1 = EstMdl1.Residuals.Raw;

figure(1)
subplot(2,1,1)
plot(ehat1)

subplot(2,1,2)
autocorr(ehat1)

%% Reamarks:there exit heteroskedatsicity and autocorrelations in the
% residuals ,indicating that we neeed ARIMA model


%% step 2: using tiem-series regression models
% TS model1 : time-series regression model 

MdlTS1 = regARIMA('ARlags',1);
[EstMdLTS1,~,logLTS1] = estimate(MdlTS1,IR10y,'x',IR1y);

% TS model2 : time-series regression model with MA(2) errors

MdlTS2 = regARIMA('MAlags',1);
[EstMdLTS2,~,logLTS2] = estimate(MdlTS2,IR10y,'x',IR1y);

% TS model3 : time-series regression model with ARMA(1,1) errors

MdlTS3 = regARIMA('ARlags',1,'MAlags',1);
[EstMdLTS3,~,logLTS3] = estimate(MdlTS3,IR10y,'x',IR1y);

%%%%compare these three TS models using likelihood ratio test 
% compare TS1 with TS3

[h1,pValue1] = lratiotest(logLTS3,logLTS1,1);

% Comments: We need to reject the null hypothesis so the unrestricted model
% performs better, we prefer the TS3

% compare TS2 with TS3

[h2,pValue2] = lratiotest(logLTS3,logLTS1,1);

% Comments: We need to reject the null hypothesis so the unrestricted model
% performs better, we prefer the TS3

% ActualLy we don't need compare TS1 and TS2.AIC an dbic FOR TS2 and TS1

[aicTS1,bicTS1] = aicbic(logLTS1,5,size(IR10y,1));
[aicTS2,bicTS2] = aicbic(logLTS2,5,size(IR10y,1));

% display the results

display([h1,pValue1;h2,pValue2;aicTS1,bicTS1;aicTS2,bicTS2])

%%% It seems that the model with ARMA(1,1) ERROR TERM PERFORMS BETTER THAN THE

%%% take a look at the residuals

[E,U,V] = infer(EstMdLTS3,IR10y,'x',IR1y);

figure(2)
subplot(2,1,1)
plot(E)

subplot(2,1,2)
plot(V)

%% heteroskedaticity and autocorrelation consistent covariance estimate

EstCovHC = hac(IR1y,IR10y,'type','HC');
EstCovHAC = hac(IR1y,IR10y);

stdhc = sqrt(diag(EstCovHC));
stdhac = sqrt(diag(EstCovHAC));

%%% the HC/HAC corrected standard deviations of beta are higher than the
%%% OLS standard deviation

