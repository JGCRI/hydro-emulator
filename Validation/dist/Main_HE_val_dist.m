% This is the main program that validates the capability of the distributed schemd of the 
% hydrological emulator (HE) in reproducing target global hydrological
% model (GHM) during the validation period.

clc;clear;close;
%The working directory here needs to be set to local directory where 
% the Valiation\dist is located.
% cd .\Validation\dist;

files=dir('..\..\WATCH_basin_data\WATCH_basin_*_grid.mat');files=struct2cell(files);files=files(1,:)';%basin-specific input data
files2=dir('..\..\Calibration\dist\Cal_dist_basin_*.mat');files2=struct2cell(files2);files2=files2(1,:)';%output from calibration
nbasin=235;%number of basins
nmon=240; %number of months used for validation
KGEval=nan(nbasin,2);%basin_id, KGE
bsn_data=nan(nmon,14,nbasin);% 240 rows of months, 14 cols:P,Robs,Rsim,Ea,PET,G,S,RE,DR,base,XS,RAIN,SNOW,SNM, 235 basins

%mapping between files and files2
mapping=nan(size(files,1),2);%2 cols: basin id of files, corresponding basin id of files2
for i=1:size(files,1)
    file=files{i};
    file2=files2{i};
    bsn_id1=str2num(file(13:end-9));%basin-specific input data
    bsn_id2=str2num(file2(16:end-4));%basin-specific calibration data
    mapping(i,:)=[bsn_id1 bsn_id2];
end

for i=1:size(files,1)      
    file=files{i};
    basin_id=mapping(i,1);   
    load(['..\..\WATCH_basin_data\' file]);
    tmpidx=find(mapping(:,2)== basin_id);%the index of file2 corresponding to the same basin_id (file)
    file2=files2{tmpidx};
    dist_cal=load(['..\..\Calibration\dist\' file2]); 
    dist_cal=dist_cal.dist_cal;   

    %take the period of 1991-2010 as the validation period in our example    
    PET=WATCH_basin_grid.PET(:,end-nmon+1:end);%potential evapotranpiration
    P=WATCH_basin_grid.P(:,end-nmon+1:end);%precipitation
    TMIN=WATCH_basin_grid.TMIN(:,end-nmon+1:end);%minimum air temperature
    Robs=WATCH_basin_grid.Robs(:,end-nmon+1:end);%Robs:observed runoff
    obsbfi=WATCH_basin_grid.obsbfi;    
    basin_name=WATCH_basin_grid.basin_name;
    basin_id=WATCH_basin_grid.basin_id;    
    grids=WATCH_basin_grid.grids;
    
    [KGE_output,bsn_output,Rsim,Ea, G, S,RE,DR,base,XS,RAIN,SNOW,SNM] = Validation_dist(PET,P,TMIN,Robs,nmon,dist_cal);  
   
    KGEval(basin_id,:)=[basin_id KGE_output];
    bsn_data(:,:,basin_id)=bsn_output;

    simbfi=nanmean(base./Rsim,2);
    name=['Val_dist_basin_' num2str(basin_id) '.mat'];
    dist_val=struct('basin_name',basin_name,'basin_id',basin_id,'grids',grids,'KGE',KGEval(basin_id,2),'P',P,...
        'PET',PET,'Rsim',Rsim,'Robs',Robs,'ET',Ea,'GW',G,'SM',S,'Recharge',RE,'DR',DR,'baseflow',base,...
        'snowpack',XS,'Rainfall',RAIN,'snowfall',SNOW,'snowmelt',SNM,'obsbfi',obsbfi,'simbfi',simbfi);   
    save(name, 'dist_val');
    if mod(i,10)==0
        disp(i)
    end
end

name2='KGE_Val_dist_glb.mat';
name3='bsn_data_Val_dist_glb.mat';
save(name2,'KGEval'); 
save(name3,'bsn_data');
fclose all;
