%% model S&P INDEX RETURN AND VOLATILITY
clc;
clear;
%% step 1 : load data
load SP500.mat;
Price =AdjClose;
Ret =  price2ret(Price);
%% step 2 : preliminary analysis
figure(1)
subplot(2,1,1)
plot(Price)

subplot(2,1,2)
plot(Ret)

T=size(rep,1);

%% step 3: specify conditional mean models
figure(2)
subplot(2,1,1)
autocorr(Ret)

subplot(2,1,2)
parcorr(Ret)

% comments: it seems that AR(1) MA(1) ARMA(1,1) AR(2) MA(2) AR(2) MA(2)
% or AMRA(2,2) for the mean equation ,but there we only try AR(1) and MA(1)
%%% and ARMA(1,1)
%% 

MdlM1 =  arima('ARLags',1);
MDlM2 =  arima('MAlags',1);
MDlM3 =  arima(1,0,1);
[EstiMdlM1,ParamCov1,logL1] =  estimate(MdlM1,Ret);
[EstiMdlM2,ParamCov2,logL2] =  estimate(MdlM2,Ret);
[EstiMdlM3,ParamCov3,logL3] =  estimate(MdlM3,Ret);

E1=infer(EstMdlM1,Ret);
E2=infer(EstMdlM2,Ret);
E3=infer(EstMdlM3,Ret);

figure(3)
subplot(3,2,1)
plot(E1)
subplot(3,2,2)
autocorr(E1)

subplot(3,2,3)
plot(E2)
subplot(3,2,4)
autocorr(E2)

subplot(3,2,5)
plot(E3)
subplot(3,2,6)
autocorr(E3)


figure(4)
subplot(3,1,1)
autocorr(E1.^2)
subplot(3,1,2)
autocorr(E2.^2)
subplot(3,1,3)
autocorr(E3.^3)


%%%% comment: Figure 3 and figure 4 together indicate taht we need
%%%% time-varying volatility models

MdlV1 =  arima('ARlags',1,'variance',garch(1,1));
MdlV2 =  arima('ARlags',1,'variance',egarch(1,1));

[EstMdlV1,ParamCovV1,LogLV1] = estimate(MdlV1,Ret);
[EstMdlV2,ParamCovV2,LogLV2] = estimate(MdlV2,Ret);

[resV1,V1] =  infer(EstMdlV1,Ret);
[resV2,V2] =  infer(EstMdlV2,Ret);

NparamV1 = size(ParamCov1,1);
NparamV2 = size(ParamCov2,1);


figure (5)
subplot(3,2,1)
plot(sqrt(252*V1))
subplot(3,2,3)
plot(resV1./sqrt(V1))
subplot(3,2,5)
autocorrl(resV1./sqrt(V1))

subplot(3,2,1)
plot(sqrt(252*V2))
subplot(3,2,3)
plot(resV2./sqrt(V2))
subplot(3,2,5)
autocorrl(resV2./sqrt(V2))

[aicV1,bicV1] =  aicbic(LogLV1,NparamV1, T); 
[aicV2,bicV2] =  aicbic(LogLV2,NparamV2, T); 

disp('Compare AR1 -GARCH(1,1) and AR1- EGARCH(1,1) using AIC and BIC')

disp('AIC         BIC')
disp([aicV1,bicV1,aicV2,bicV2])




