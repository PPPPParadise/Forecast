% modeling longtime interest rate
clear;
clc;

load IRdata
%%preliminary data analysis
figure(1) %plot two time series of interest
plot([interest1y,interest10y])


%% step1: using OLS to estimate Model 1 : y = alpha +beta* x+e
%  use the matlab buld-in function fitlm

EstMdl1=fitlm(interest1y,interest10y);

disp(EstMdl1)

%take a look at the residuals
ehat1 = EstMdl1.Residuals.Raw;

figure(2)
subplot(2,1,1)
plot(ehat1)

subplot(2,1,2)
autocorr(ehat1)

%% remarks: the residuals are hightly persistent ,indicating that the 
% step 2: using OLS to estimate Model 2:dy=alpha +beta*dx +e

IR10y = diff(interest10y);
IR1y = diff(interest1y);
EstMdl2 = fitlm(IR10y,IR1y);
disp(EstMdl2)
ehat2 = EstMdl2.Residuals.Raw;

figure(3)
subplot(2,1,1)
plot(ehat2)

subplot(2,1,2)
autocorr(ehat2)


%%reamarks:there exit heteroskedatsicity and autocorrelations in the
%%residuals ,indicating that we neeed ARIMA model
%%step 3: using tiem-series regression models
% TS model1 : time-series regression model 
MdlTS1 = regARIMA('MAlags',1,'Beta',NaN);
[EstMdLTS1,~,logLTS1] = estimate(MdlTS1,IR10y,'x',IR1y);


% TS model2 : time-series regression model with MA(2) errors
MdlTS2 = regARIMA('MAlags',[1,2],'Beta',NaN);
[EstMdLTS2,~,logLTS2] = estimate(MdlTS2,IR10y,'x',IR1y);

% TS model3 : time-series regression model with ARMA(1,1) errors
MdlTS3 = regARIMA('ARlags',1,'MAlags',1,'Beta',NaN);
[EstMdLTS3,~,logLTS3] = estimate(MdlTS3,IR10y,'x',IR1y);

%%%%compare these three TS models using likelihood ratio test 
% compare TS1 with TS2
[h1,pValue1] = lratiotest(logLTS2,logLTS1,1);

% compare TS3 with TS1

[h2,pValue2] = lratiotest(logLTS3,logLTS1,1);


% AIC an dbic FOR TS2 and TS3

[aicTS2,bicTS2] = aicbic(logLTS2,5,size(IR10y,1));
[aicTS3,bicTS3] = aicbic(logLTS3,5,size(IR10y,1));

% display the results

display('-------------------------');
display([h1,pValue1;h2,pValue2;aicTS2,bicTS2;aicTS3,bicTS3])



%%% it seems that the model with MA(2) ERROR TERM PERFORMS BETTER THAN THE
%%% MODELS WITH MA(1) and ARMA(1,1) error term



%%% take a look at the residuals

[E,U,V] = infer(EstMdlTS2,IR10y,'x',IR1y);

figure(4)
subplot(2,1,1)
plot(E)

subplot(2,1,2)
plot(V)

%% heteroskedaticity and autocorrelation consistent covariance estimate

EstCovHC = hac(IR1y,IR10y,'type','HC');
EstCovHAC = hac(IR1y,IR10y);

stdhc = sqrt(diag(EstCovHC))
stdhac = sqrt(diag(EstCovHAC))

%%% the HC/HAC corrected standard deviations of beta are higher than the
%%% OLS standard deviation

%%%

