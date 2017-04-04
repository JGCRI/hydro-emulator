function objfun=ObjFun_ABCD_dist(pars,P,PET,Robs,Inv,TMIN,obsbfi)

[Rsim,Ea,G, S,RE,DR,base,XS,RAIN,SNOW,SNM]=ABCD_noconstrain(pars,P,PET,Inv,TMIN);

observed1=nanmean(Robs(:,end-239:end))';modelled1=nanmean(Rsim(:,end-239:end))';

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
