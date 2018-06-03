load Data_USEconModel
DataTable.RGDP = DataTable.GDP./DataTable.GDPDEF*100;

figure(1)
subplot(3,1,1)
plot(DataTable.Time,DataTable.RGDP,'r');
title('Real GDP')
grid on 
subplot(3,1,2)
plot(DataTable.Time,DataTable.M1SL,'b');
title('M1')
grid on
subplot(3,1,3);
plot(DataTable.Time,DataTable.TB3MS,'k')
title('3-mo T-bill')
grid on

% The real GDP and M1 data appear to grow exponentially
% while the T-bill returns show no exponential growth. 
% so we ake a difference of the logarithms of the real GDP and M1
% Also, stabilize the T-bill series by taking the first difference. 

rgdpg = price2ret(DataTable.RGDP);
m1slg = price2ret(DataTable.M1SL);
dtb3ms = diff(DataTable.TB3MS);
Data = array2timetable([rgdpg m1slg dtb3ms],...
    'RowTimes',DataTable.Time(2:end),'VariableNames',{'RGDP' 'M1SL' 'TB3MS'});

figure(2)
subplot(3,1,1)
plot(Data.Time,Data.RGDP,'r');
title('Real GDP')
grid on
subplot(3,1,2);
plot(Data.Time,Data.M1SL,'b');
title('M1')
grid on
subplot(3,1,3);
plot(Data.Time,Data.TB3MS,'k'),
title('3-mo T-bill')
grid on

Data{:,1:2} = 100*Data{:,1:2};
figure(3)
plot(Data.Time,Data.RGDP,'r');
hold on
plot(Data.Time,Data.M1SL,'b');
datetick('x')
grid on
plot(Data.Time,Data.TB3MS,'k');
legend('Real GDP','M1','3-mo T-bill');
hold off

idx = all(~ismissing(Data),2);
Data = Data(idx,:);

numseries = 3;
dnan = diag(nan(numseries,1));
seriesnames = {'Real GDP','M1','3-mo T-bill'};
VAR2diag = varm('AR',{dnan dnan},'SeriesNames',seriesnames);
VAR2full = varm(numseries,2);
VAR2full.SeriesNames = seriesnames;
VAR4diag = varm('AR',{dnan dnan dnan dnan},'SeriesNames',seriesnames);
VAR4full = varm(numseries,4);
VAR4full.SeriesNames = seriesnames;

idxPre = 1:4;
T = ceil(.9*size(Data,1));
idxEst = 5:T;
idxF = (T+1):size(Data,1);
fh = numel(idxF);

[EstMdl1,EstSE1,logL1,E1] = estimate(VAR2diag,Data{idxEst,:},...
    'Y0',Data{idxPre,:});
[EstMdl2,EstSE2,logL2,E2] = estimate(VAR2full,Data{idxEst,:},...
    'Y0',Data{idxPre,:});
[EstMdl3,EstSE3,logL3,E3] = estimate(VAR4diag,Data{idxEst,:},...
    'Y0',Data{idxPre,:});
[EstMdl4,EstSE4,logL4,E4] = estimate(VAR4full,Data{idxEst,:},...
    'Y0',Data{idxPre,:});

EstMdl1.Description
EstMdl2.Description
EstMdl3.Description
EstMdl4.Description

results1 = summarize(EstMdl1);
np1 = results1.NumEstimatedParameters;
results2 = summarize(EstMdl2);
np2 = results2.NumEstimatedParameters;
results3 = summarize(EstMdl3);
np3 = results3.NumEstimatedParameters;
results4 = summarize(EstMdl4);
np4 = results4.NumEstimatedParameters;

reject1 = lratiotest(logL2,logL1,np2 - np1);
reject3 = lratiotest(logL4,logL3,np4 - np3);
reject4 = lratiotest(logL4,logL2,np4 - np2);

