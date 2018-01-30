function [KGE]=KGE(observed,modelled)
    
    sdmodelled=std(modelled);
    sdobserved=std(observed); 
    mmodelled=mean(modelled);
    mobserved=mean(observed);
    r=corr(observed,modelled);
    relvar=sdmodelled/sdobserved;
    bias=mmodelled/mobserved;
    
    KGE=1-sqrt( ((r-1)^2) + ((relvar-1)^2)  + ((bias-1)^2) );
   