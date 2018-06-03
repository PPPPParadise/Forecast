%%% model S&P 500 index return and volatility
clc;
clear;

%% Step 1: load data
load SP500.mat;

Price = AdjClose;
Ret   = price2ret(Price);

T = size(Ret, 1);

%% Step 2: Preliminary analysis
figure(1)
subplot(2, 1, 1)
plot(Price)

subplot(2, 1, 2)
plot(Ret)

%% Step 3: Specify conditional mean models
figure(2)
subplot(2, 1, 1)
autocorr(Ret)

subplot(2, 1, 2)
parcorr(Ret)
%%
%%%% Comments: it seems that we need AR(1), MA(1), ARMA(1, 1), AR(2),
%%%% MA(2), or ARMA(2, 2) for the mean equation. But here we only AR(1) and
%%%% MA(1), and ARMA(1, 1)
MdlM1 = arima('ARLags', 1);
MdlM2 = arima('MALags', 1);
MdlM3 = arima(1, 0, 1);

[EstMdlM1, ParamCov1, LogL1] = estimate(MdlM1, Ret);
[EstMdlM2, ParamCov2, LogL2] = estimate(MdlM2, Ret);
[EstMdlM3, ParamCov3, LogL3] = estimate(MdlM3, Ret);

E1 = infer(EstMdlM1, Ret);
E2 = infer(EstMdlM2, Ret);
E3 = infer(EstMdlM3, Ret);

%%
figure(3)
subplot(3, 2, 1)
plot(E1)
subplot(3, 2, 2)
autocorr(E1)

subplot(3, 2, 3)
plot(E2)
subplot(3, 2, 4)
autocorr(E2)

subplot(3, 2, 5)
plot(E3)
subplot(3, 2, 6)
autocorr(E3)

figure(4)
subplot(3, 1, 1)
autocorr(E1.^2)
subplot(3, 1, 2)
autocorr(E2.^2)
subplot(3, 1, 3)
autocorr(E3.^2)

%%%%% Comment: Figure 3 and Figure 4 together indicate that we need time-varying volatility models

%% Step 4: combine mean models and vol models together
% For example: AR(1)-GARCH(1, 1) and AR(1)-EGARCH(1, 1)
MdlV1 = arima('ARLags', 1, 'variance', garch(1, 1));
MdlV2 = arima('ARLags', 1, 'variance', egarch(1, 1));

[EstMdlV1, ParamCovV1, LogLV1] = estimate(MdlV1, Ret);
[EstMdlV2, ParamCovV2, LogLV2] = estimate(MdlV2, Ret);

NparamV1 = size(ParamCovV1, 1);
NparamV2 = size(ParamCovV2, 1);

[resV1, V1] = infer(EstMdlV1, Ret);
[resV2, V2] = infer(EstMdlV2, Ret);

figure(5)
subplot(3, 2, 1)
plot(sqrt(252*V1))
subplot(3, 2, 3)
plot(resV1./sqrt(V1))
subplot(3, 2, 5)
autocorr(resV1./sqrt(V1))

subplot(3, 2, 2)
plot(sqrt(252*V2))
subplot(3, 2, 4)
plot(resV2./sqrt(V2))
subplot(3, 2, 6)
autocorr(resV2./sqrt(V2))

[aicV1, bicV1] = aicbic(LogLV1, NparamV1, T);
[aicV2, bicV2] = aicbic(LogLV2, NparamV2, T);

disp('Compare AR(1)-GARCH(1, 1) and AR(1)-EGARCH(1, 1) Using AIC and BIC')
disp('      AIC           BIC')
disp([aicV1, bicV1; aicV2, bicV2])