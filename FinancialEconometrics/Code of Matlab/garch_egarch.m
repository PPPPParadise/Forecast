[EstMdl1,ParamCov1,LogL1]=
Mdl2=Mdl1
Mdl2.Ditributation=struct('Name','t','DoF',NaN)

[h,pV,stat,Cv]=lratiotest(lOGl2,loGl1,1)

V=infer(EstMdl2,y);
annulizedVol = sqrt(252*V);

y= price2ret(AdjClose);
plot(y)
mdl1=egarch(1,1)

%% price2ret is equivalent to diff(log(price))

Mdl1 = egarch('GARCH_ags',1'ARCH_ags',1,'offsert',NaN,'leverage',NaN)
[EstMdl1,ParamCov1,LogL1]= estimate(mdl1,y)

