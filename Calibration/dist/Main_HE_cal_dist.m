% This is the main program that calibrates the distributed schemd of the hydrological emulator (HE) 
% agaist target global hydrological model (GHM) and  provides model output and evaluations of  
% HE performance during the calibration period

clc;clear;close;
%The working directory here needs to be set to local directory where 
% the Calibration\dist is located.
% cd .\Calibration\dist;

files=dir('..\..\WATCH_basin_data\WATCH_basin_*_grid.mat');files=struct2cell(files);files=files(1,:)';%basin-specific input data
nbasin=235;%number of basins
nmon=240; %number of months used for calibration
KGEval=nan(nbasin,2);%basin_id, KGE
bsn_data=nan(nmon,14,nbasin);% 240 rows of months, 14 cols:P,Robs,Rsim,Ea,PET,G,S,RE,DR,base,XS,RAIN,SNOW,SNM, 235 basins

for i=1:size(files,1)      
    file=files{i};    
    load(['..\..\WATCH_basin_data\' file]);

    %take the period of 1971-1990 as the calibration period in our example    
    PET=WATCH_basin_grid.PET(:,1:nmon);PET0=repmat(PET,1,2); 
    P=WATCH_basin_grid.P(:,1:nmon);P0=repmat(P,1,2);
    TMIN=WATCH_basin_grid.TMIN(:,1:nmon);TMIN0=repmat(TMIN,1,2);
    Robs=WATCH_basin_grid.Robs(:,1:nmon);Robs0=repmat(Robs,1,2);%Robs:observed runoff
    obsbfi=WATCH_basin_grid.obsbfi;%baseflow index
    basin_name=WATCH_basin_grid.basin_name;
    basin_id=WATCH_basin_grid.basin_id;
    Inv0=[20,100,500];%initial runoff,Soil moisture storage, groundwater storage    
       
    datestr(now)
    %spin-up the model for a period of 40 years by repeating the data of 1971-1990 twice,and calibrate the model
    [pars]=Calibration_dist(PET,P,TMIN,Robs,obsbfi);    
    datestr(now)

    %run the abcd model to get a steady state for the initial values of runoff,soil moisture storage, groundwater storage
    [Rsim1,Ea1, G1, S1,RE1,DR1,base1,XS1,RAIN1,SNOW1,SNM1]=abcd(pars,P0,PET0,Inv0,TMIN0);     
    %take the state of the last 3 December values as the initial values 
    Inv=[mean(nanmean(Rsim1(:,end-35:12:end))),mean(nanmean(S1(:,end-35:12:end))),mean(nanmean(G1(:,end-35:12:end)))];%the average of last 3 Decembers
    
    % use the initial values of steady state to re-run the model again
    [Rsim,Ea, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]=abcd(pars,P,PET,Inv,TMIN);    
    data2=reshape(nanmean([P,Robs, Rsim,Ea,PET, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]),nmon,[]);%Rsim: simulated runoff, see other variables in abcd.m
    
    KGEval(basin_id,:)=[basin_id KGE(nanmean(Robs)',nanmean(Rsim)')];
    bsn_data(:,:,basin_id)=data2;

    simbfi=nanmean(base./Rsim,2);
    name=['Cal_dist_basin_' num2str(basin_id) '.mat'];
    dist_cal=struct('basin_name',basin_name,'basin_id',basin_id,'pars',pars,'KGE',KGEval(basin_id,2),'P',P,'PET',PET,...
        'Rsim',Rsim,'Robs',Robs,'ET',Ea,'GW',G,'SM',S,'Recharge',RE,'DR',DR,'baseflow',base,...
        'snowpack',XS,'Rainfall',RAIN,'snowfall',SNOW,'snowmelt',SNM,'obsbfi',obsbfi,'simbfi',simbfi);   
    save(name, 'dist_cal');
    if mod(i,10)==0
        disp(i)
    end
end

name2='KGE_Cal_dist_glb.mat';
name3='bsn_data_Cal_dist_glb.mat';
save(name2,'KGEval'); 
save(name3,'bsn_data');
fclose all;
