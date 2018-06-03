% Financial econometrics homework 1 by Shenghua Du
%% Preprocess the data of 25 portfolios and the SMB HML RF MktRF
% load the data
load researchdata

%% Quesiton(a): Estimate the CAPM model of 25 porfolios

X1=MktRF-RF;
CAPMBetaMatrix = zeros(25,1);
CAPMconstantMatrix = zeros(25,1);
for  i=1:25
    CAPM = fitlm(X1,Porfolio(:,i));
    disp(CAPM);
    CAPMBetaMatrix(i,:) = CAPM.Coefficients.Estimate(2);
    CAPMconstantMatrix(i,:)= CAPM.Coefficients.Estimate(1);
end


%% Question(b): According to the CAPM model, Beta is the measerment of risk.
% If Beta = 1 it means the risk and revenue will be same as the market porfolio
% R^2 represents the percentage that the model can explain.The higher is
% R^2, the better is the model.


%% Question(c):we do the t-test to the Beta.

[h1,pValue1,ci1,stats1] = ttest(CAPMBetaMatrix,1)

% The null hypothesis H0 is Beta = 1.
% The alternative hypothesis H1 is Beta != 1
% According to the h,pValue and tStat We know we need to reject the null hypothesis.
% So we can't consider Beta equal to 1.


%% Question(d):we do the t-test to the constant

[h2,pValue2,ci2,stats2] = ttest(CAPMBetaMatrix)

% The null hypothesis H0 is constant = 0.
% The alternative hypothesis H1 is constatn != 1
% According to the h,pValue and tStat We know we need to reject the null hypothesis.
% So we can't consider constatnt equal to 0.


%% Question(e):estimate the Fama-French three-factor model

X2 =[MktRF-RF,SMB,HML];
FFBetaMatrix = zeros(25,3);
for  i=1:25
    FF = fitlm(X2,Porfolio(:,i));
    disp(FF);
    FFBetaMatrix(i,:) = FF.Coefficients.Estimate(2:4);
end

% Comments: we can see that the R^2 is much higher than the CAPM model.


%% Question(f):we do the F-test to the coefficients for the two new factors.

[h3,pValue3,ci3,stats3] = vartest2(FFBetaMatrix(:,2),FFBetaMatrix(:,3))

% The null hypothesis is beta2 = beta3
% The alternative hypothesis is 
% According to the h,pValue and tStat We know we can't reject the null hypothesis.


%% Question(g):

% Estimate CAPM model'market prices lamda and price error alpha.

CAPMlamdaMatrix = zeros(1101,1);
CAPMalphaMatrix = zeros(1101,1);

for i = 1:1101
    
 y1=(Porfolio(i,:))';
 X3=(CAPMBetaMatrix(:,1));
 lm = fitlm(X3,y1);
 CAPMlamdaMatrix(i) = lm.Coefficients.Estimate(2);
 CAPMalphaMatrix(i) = lm.Coefficients.Estimate(1);
 
end

% calculate the average of lamda and alpha of CAPM model.

CAPMlamda = mean(CAPMlamdaMatrix);
CAPMalpha = mean(CAPMalphaMatrix);

% Estimate Fama-French three-factor model' market prices lamda and price error alpha.

FFlamdaMatrix = zeros(1101,3);
FFalphaMatrix = zeros(1101,1);

for i = 1:1101
    
 y2=(Porfolio(i,:))';
 X4=(FFBetaMatrix(:,1:3));
 lm = fitlm(X4,y2);
 FFlamdaMatrix(i,1:3) = lm.Coefficients.Estimate(2:4);
 FFalphaMatrix(i) = lm.Coefficients.Estimate(1);
 
end

% Calculate the average of lamda and alpha of Fama-French three-factor

FFlamda = mean(FFlamdaMatrix);
FFalpha = mean(FFalphaMatrix);

% (a) The market risk premia of each porfolio is CAPM_Market_Risk_Premia
% and Fama-French three-factor model is FF_Market_Risk_Premia
% The price error of each porfolio is the CAPMalpha and FFalpha matrix.
CAPMBetatrans = repmat(CAPMBetaMatrix,1,1101);
CAPM_Market_Risk_Premia = CAPMBetatrans*CAPMlamdaMatrix;

FFBetatrans1 = repmat(FFBetaMatrix(:,1),1,1101);
FFBetatrans2 = repmat(FFBetaMatrix(:,2),1,1101);
FFBetatrans3 = repmat(FFBetaMatrix(:,3),1,1101);
FF_Market_Risk_Premia1 = FFBetatrans1*FFlamdaMatrix(:,1);
FF_Market_Risk_Premia2 = FFBetatrans2*FFlamdaMatrix(:,2);
FF_Market_Risk_Premia3 = FFBetatrans3*FFlamdaMatrix(:,3);
FF_Market_Risk_Premia = [FF_Market_Risk_Premia1,FF_Market_Risk_Premia2,FF_Market_Risk_Premia3];

% (b) CAPMalpha = 0.6323 and FFalpha = 1.9996 so the CAPM model's price
% error is smaller




















