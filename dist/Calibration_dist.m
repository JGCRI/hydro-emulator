clc;clear;close;
cd ..\calibration_data_dist;
% This is the source codes for model calibration
files=dir('..\watch_basin_data\WATCH_basin_*_grid.mat');files=struct2cell(files);files=files(1,:)';%basin-specific input data
KGEval=nan(235,2);%basin_id, KGE
bsn_data=nan(240,10+4,235);%240 rows of months, 14 cols:P,Robs,Rsim,Ea,PET,G,S,RE,DR,base,XS,RAIN,SNOW,SNM, 235 basins

for i=1:size(files,1)
   file=files{i};
    bsn_id=str2num(file(13:end-9));
    load(['..\watch_basin_data\' file]);

PET=(WATCH_basin_grid.PET(:,1:240));PET0=repmat(PET,1,2);
P=(WATCH_basin_grid.P(:,1:240));P0=repmat(P,1,2);
TMIN=(WATCH_basin_grid.TMIN(:,1:240));TMIN0=repmat(TMIN,1,2);
Robs=(WATCH_basin_grid.Robs(:,1:240));Robs0=repmat(Robs,1,2);%Robs:observed runoff
maxstor=(WATCH_basin_grid.maxstor);maxstor0=repmat(maxstor,1);%max soil water storage
bfi=(WATCH_basin_grid.bfi);%baseflow index

Inv0=[20,100,500];%initial runoff,Soil moisture storage, groundwater storage
LB=[0.001,0.1,0,0,0];UB=[1,4,1,1,1]; %a,b,c,d,m
nn=length(LB);

%%
obsbfi0=bfi;
datestr(now)
pars=ga(@(pars)ObjFun_ABCD_dist(pars,P0,PET0,Robs0,Inv0,TMIN0,obsbfi0),nn,[],[],[],[],LB,UB); %calibration
datestr(now)

[Rsim1,Ea1, G1, S1,RE1,DR1,base1,XS1,RAIN1,SNOW1,SNM1]=ABCD_noconstrain(pars,P0,PET0,Inv0,TMIN0);
Inv=[mean(nanmean(Rsim1(:,end-35:12:end))),mean(nanmean(S1(:,end-35:12:end))),mean(nanmean(G1(:,end-35:12:end)))];%the average of last 3 Decembers

[Rsim,Ea, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]=ABCD_noconstrain(pars,P,PET,Inv,TMIN);
data2=reshape(nanmean([P,Robs, Rsim,Ea,PET, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]),240,[]);%Rsim: simulated runoff, see other variables in ABCD_noconstrain.m

KGEval(bsn_id,:)=[bsn_id KGE(nanmean(Robs)',nanmean(Rsim)')];
bsn_data(:,:,bsn_id)=data2;

simbfi=nanmean(base./Rsim,2)';
name=['Cal_dist_noconstrain_basin_' num2str(bsn_id) '.mat'];
dist_nocstrn_cal=struct('basin_id',bsn_id,'pars',pars,'KGE',KGEval(i,2),'precipitation',P,'PET',PET,...
    'maxstor',maxstor, 'Rsim',Rsim,'Robs',Robs,'Ea',Ea,'GW',G,'SM',S,'Recharge',RE,'DR',DR,'baseflow',base,...
    'snowpack',XS,'Rainfall',RAIN,'snowfall',SNOW,'snowmelt',SNM,'obsbfi',obsbfi0,'simbfi',simbfi);
save(name, 'dist_nocstrn_cal');

disp(i)
end
name2=['KGE_Cal_lump_noconstrain_glb_hgpet' num2str(ceil(i/10)) '.mat'];
name3=['bsn_data_Cal_lump_noconstrain_glb_hgpet' num2str(ceil(i/10)) '.mat'];
save(name2,'KGEval'); %mean KGE is 0.7661
save(name3,'bsn_data');
fclose all;
