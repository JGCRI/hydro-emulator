function objfun=ObjFun_abcd_lump(pars,P,PET,Robs,Inv,TMIN,obsbfi)
% pars: parameters (a,b,c,d,m)
% P:precipitation
% PET:potential evapotranspiration
% Robs: observed runoff (benchmark runoff product)
% Inv: initial values for runoff,soil moisture storage, groundwater storage
% TMIN:minimum air temperature
% obsbfi: observed baseflow index

% see comments in the abcd.m for meaning of each variable below
[Rsim,Ea,G, S,RE,DR,base,XS,RAIN,SNOW,SNM]=abcd(pars,P,PET,Inv,TMIN); 

%Use simulations of the last 20 years for model performance evaluation
observed1=(Robs(:,end-239:end))';modelled1=(Rsim(:,end-239:end))';

sdmodelled1=std(modelled1);
sdobserved1=std(observed1); 
mmodelled1=mean(modelled1);
mobserved1=mean(observed1);
r1=corr(observed1,modelled1);
relvar1=sdmodelled1/sdobserved1;
bias1=mmodelled1/mobserved1;

simbfi=nanmean(base./Rsim,2);
observed2=obsbfi;modelled2=simbfi;
diffr=nansum(abs(observed2-modelled2))/size(obsbfi,1);
objfun=sqrt(((r1-1)^2)+((relvar1-1)^2)+((bias1-1)^2))+diffr;
end
