MdlG1=gjr(1,1)
MdlG1=gjr('GARCH_ags',1,'ARCH_ags',1,'leveage',NaN)
[EstMdl1,ParamCov1,LogL1] =  estimate(MdlG1,y);
