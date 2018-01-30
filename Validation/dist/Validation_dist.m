% This function is to get the calibrated parameters (a,b,c,d,m) for the distributed scheme 
% of the hydrological emulator (HE) from the output of the calibration process,
% and then evaluate the HE's effectiveness in reproducing the target global
% hydrological model (GHM) being emulated via Kling-Gupta efficiency (KGE).

function [KGE_output,bsn_output,Rsim,Ea, G, S,RE,DR,base,XS,RAIN,SNOW,SNM] = Validation_dist(PET,P,TMIN,Robs,nmon,dist_cal)  
    %KGE_output: KGE value during the validation period
%   %bsn_output: output from the distributed scheme of the hydrological emulator during the validation period
%   %dist_cal: the basin-specific structure arragy output from the calibration process
    %see abcd.m for the meaning of other variables
    
    pars=dist_cal.pars;
    %take the average of the last 3 Decembers varialbe values from the output of the calibration 
    %for initial values of runoff,soil moisture storage, groundwater storage
    Inv0=[mean(mean(dist_cal.Rsim(:,end-35:12:end))) mean(mean(dist_cal.SM(:,end-35:12:end))) mean(mean(dist_cal.GW(:,end-35:12:end)))];
    
    %run the abcd model to get a steady state for the initial values of runoff,soil moisture storage, groundwater storage
    [Rsim1,Ea1, G1, S1,RE1,DR1,base1,XS1,RAIN1,SNOW1,SNM1]=abcd(pars,P,PET,Inv0,TMIN); 
    %take the state of the last 3 December values as the initial values 
    Inv=[mean(nanmean(Rsim1(:,end-35:12:end))),mean(nanmean(S1(:,end-35:12:end))),mean(nanmean(G1(:,end-35:12:end)))];%the average of last 3 Decembers
    % use the  initial values of steady state  to re-run the model again
    [Rsim,Ea, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]=abcd(pars,P,PET,Inv,TMIN);
    
    bsn_output=reshape(nanmean([P,Robs, Rsim,Ea,PET, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]),nmon,[]);%see meanings of the variables in abcd.m
    KGE_output= KGE(nanmean(Robs,2),nanmean(Rsim,2));
    
     
