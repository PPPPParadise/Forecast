load Data_USEconModel
cpi = DataTable.CPIAUCSL;
unrate = DataTable.UNRATE;
plot(cpi);
plot(unrate);
Mdl=varm(2,4);
Mdl.Trend=NaN;
Mdl.Trend=[nan,0]';
c=[1;1;0];
Phi1 = {[0.2 -0.1 0.5; -0.4 0.2 0; -0.1 0.2 0.3]}; 
delta = [1.5; 2; 0];
Sigma = [0.1 0.01 0.3; 0.01 0.5 0; 0.3 0 1];
Mdl = varm('Constant',c,'AR',Phi1,'Trend',delta,'Covariance',Sigma);
Mdl2=Mdl;
Mdl.AR=[Phi1,nan(3)];


%% estimate  the VAR model

load Data_USEconModel
plot(DataTable.Time,DataTable.CPIAUCSL);
title('Consumer Price Index');
ylabel('Index');
xlabel('Date');

figure;
plot(DataTable.Time,DataTable.UNRATE);
title('Unemployment rate');
ylabel('Percent');
xlabel('Date');


rcpi = price2ret(DataTable.CPIAUCSL);
unrate = DataqTable.UNRATE(2:end);

subplot()

Mdl = varm(2,4);
Y= [100*rcpi,unrate];
EstMdl = estimate(Mdl,Y);
summarize(EstMdl);


Mdl2 = varm(2,1);
EstMdl2 = estimate(Mdl2,Y);
summarize(EstMdl2);

Mdl3 = varm(2,2);
EstMdl3 = estimate(Mdl3,Y);
summarize(EstMdl3);

Mdl4 = varm(2,3);
EstMdl4 = estimate(Mdl4,Y);
summarize(EstMdl4);


