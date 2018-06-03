% Homework 2 of Financial econometrics by Shenghua Du
% I choose the S&P 500 index and Intel stock from 1998-5-5 to 2018-5-5
% weekly data

load homework2data

% Preliminary analysis

figure(1)
subplot(2,1,1)
plot(SP500AdjClose)

subplot(2,1,2)
plot(IntelAdjClose)

Indexreturn = price2ret(SP500AdjClose);
Intelreturn = price2ret(IntelAdjClose);


%% Question(a) 

figure(2)
subplot(2,1,1)
plot(Indexreturn)

subplot(2,1,2)
plot(Intelreturn)

Indexskewness=skewness(Indexreturn);
Intelskewness=skewness(Intelreturn);

Indexkurtosis=kurtosis(Indexreturn);
Intelkurtosis=kurtosis(Intelreturn);

% Comments: The skewness of index is -0.7955 
% The skewness of intel stock is -0.5216
% The kurtosis of index is 9.5392
% The kurtosis of intel stock is  7.0026
% Both for the index or the stock,the skewness is less than zero,
% which means the distrubition is left-skewed,fat-tailed
% The kurtosis of them is more than 3,
% which means the distribution is leptokurtic distribution.

figure(3)
subplot(2,2,1)
autocorr(Indexreturn.^2)

subplot(2,2,2)
parcorr(Indexreturn.^2)

subplot(2,2,3)
autocorr(Intelreturn.^2)

subplot(2,2,4)
parcorr(Intelreturn.^2)

% Comments: The plot tells us we needs time-varying volatility
% to build our model.


%% Question(b)

IndexMdl = garch('GARCHLags',1,'ARCHLags',1,'offset',NaN);
[EstIndex,ParamCovIndex,logLIndex,infoIndex] =  estimate(IndexMdl,Indexreturn);

IntelMdl = garch('GARCHLags',1,'ARCHLags',1,'offset',NaN);
[EstIntel,ParamCovIntel,logLIntel,infoIntel] =  estimate(IntelMdl,Intelreturn);

IndexV = infer(EstIndex,Indexreturn);
IntelV = infer(EstIntel,Intelreturn);

figure(4)
subplot(2,1,1)
plot(sqrt(252*IndexV))

subplot(2,1,2)
plot(sqrt(252*IntelV))

% Comments:Intel stock is less influenced by 2008 financial crisis
% But the S&P index is significantly infuenced by it.


%% Question(c)

Indexunvar = EstIndex.Constant/(1-cell2mat(EstIndex.GARCH)-cell2mat(EstIndex.ARCH));
Intelunvar = EstIntel.Constant/(1-cell2mat(EstIntel.GARCH)-cell2mat(EstIntel.ARCH));

Indexsamplevar = var(Indexreturn);
Intelsamplevar = var(Intelreturn);

% Comments:We can see that the unconditional variance of S&P 500 index is
% 9.1258e-04,almost equal to the sample variance of returns 6.0380e-04
% the unconditional variance of Intel stock is 0.0025 almost equal to 
% the sample variance of returns is 0.0024


%% Question(d)

u1 = EstIndex.Offset;
u2 = EstIntel.Offset;

z1 = (Indexreturn - u1)./sqrt(IndexV);
z2 = (Intelreturn - u2)./sqrt(IntelV);

figure(5)
subplot(2,1,1)
plot(z1)

subplot(2,1,2)
plot(z2)

z1skewness = skewness(z1);
z2skewness = skewness(z2);

z1kurtosis = kurtosis(z1);
z2kurtosis = kurtosis(z2);

disp('-------------------------------------------------------------------')
disp('   skewness  kurtosis')
disp([z1skewness,z1kurtosis;z2skewness,z2kurtosis])

% Comments:z1skewness and z2skewness is not equal to zero
% z1kurtosis and z2kurtosis is more than 3.So they are not consistent
% with the conditional normality assumption,which means the distrubition
% is left-skewed,fat-tailed and leptokurtic distribution.
% According to the plot,Some extreme situations and outliers like 2008
% financial crisis has influenced the distribution.


%% Question(e)

v1forecast = forecast(EstIndex,50);
v2forecast = forecast(EstIntel,50);

figure(6)
subplot(2,1,1)
plot(Indexreturn)
hold on
plot(1045:1094,v1forecast,':','LineWidth',2);
hold off

subplot(2,1,2)
plot(Intelreturn)
hold on
plot(1045:1094,v2forecast,':','LineWidth',2);
hold off


%% Question(f)

figure(7)
subplot(2,1,1)
autocorr(z1.^2)

subplot(2,1,2)
autocorr(z2.^2)

% Comments: According to the autocorrelation plot both of the two sequences
% don't have autocorrelation.So the time varying volatility has bee captured
% by the GARCH model


%% Question(g)

% I will use GJR-GARCH model cause it seems negative return shocks have a bigger
% effect on volatility

IndexMdl1 = gjr('GARCHLags',1,'ARCHLags',1,'LeverageLags',1,'Offset',NaN);
IntelMdl1 = gjr('GARCHLags',1,'ARCHLags',1,'LeverageLags',1,'Offset',NaN);

[EstIndex1,ParamIndexCov1,logLIndex1,infoIndex1] = estimate(IndexMdl1,Indexreturn);
[EstIntel1,ParamIntelCov1,logLIntel1,infoIntel1] = estimate(IntelMdl1,Intelreturn);

% i.Comments:The model specification can be seen in the EstIndex1 and EstIntel1

IndexV1 = infer(EstIndex1,Indexreturn);
IntelV1 = infer(EstIntel1,Intelreturn);

u11 = EstIndex1.Offset;
u21 = EstIntel1.Offset;
z11 = (Indexreturn - u11)./sqrt(IndexV);
z21 = (Intelreturn - u21)./sqrt(IntelV);

figure(8)
subplot(2,1,1)
autocorr(z11.^2)

subplot(2,1,2)
autocorr(z21.^2)

% ii.Comments:According to the autocorrelation plot both of the two sequences
% don't have autocorrelation.So we can consider it as standardized residuals

NparamIndex = size(ParamIndexCov1,1);
NparamIntel = size(ParamIntelCov1,1);

T = size(Indexreturn, 1);

[aicIndex, bicIndex] = aicbic(logLIndex, NparamIndex,T);
[aicIntel, bicIntel] = aicbic(logLIntel, NparamIntel,T);
[aicIndex1, bicIndex1] = aicbic(logLIndex1, NparamIndex,T);
[aicIntel1, bicIntel1] = aicbic(logLIntel1, NparamIntel,T);

disp('Compare Index GARCH(1, 1) and GJR-EGARCH(1, 1) Using AIC and BIC')
disp('      AIC           BIC')
disp([aicIndex, bicIndex; aicIndex1, bicIndex1])
disp('--------------------------------------------------------------------')
disp('Compare Intel GARCH(1, 1) and GJR-EGARCH(1, 1) Using AIC and BIC')
disp('      AIC           BIC')
disp([aicIntel, bicIntel; aicIntel1, bicIntel1])


[h1,pValue1,stat1,cValue1] = lratiotest(logLIndex1,logLIndex,1);
[h2,pValue2,stat2,cValue2] = lratiotest(logLIntel1,logLIntel,1);

% iii.Comments: As for the S&P 500 index,according to the AIC/BIC the
% GJR-GARCH's aic and bic is less.So we should choose the GJR-GARCH model.
% And the Likelihood ratio test also shows the unrestricted model(GJR-GARCH)
% performs better.

% Commets: As for the Intel stock,according to the AIC/BIC the GARCH's
% aic and bic is less but the difference is insignificant and we can 
% consider them as same.Then According to the likelihood ratio test,
% the restricted model(GARCH) is better.

% Actually I don't know how to compare when the two method conflicts
% If possible please tell us in the class.

