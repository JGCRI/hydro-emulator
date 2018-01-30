% This function is to calibrate the lumped scheme of the hydrological emulator (HE) 
% agaist the targe global hydrological model (GHM) to get optimized parameters (a,b,c,d,m)

function [pars] = Calibration_lump(PET,P,TMIN,Robs,BFI)  
    %repeating the input data twice is to spin-up the model for calibration    
    PET0=repmat(PET,1,2); 
    P0=repmat(P,1,2);
    TMIN0=repmat(TMIN,1,2);
    Robs0=repmat(Robs,1,2);%Robs:observed runoff    

    Inv0=[20,100,500];%initial runoff,Soil moisture storage, groundwater storage
    LB=[0.001,0.1,0,0,0];UB=[1,4,1,1,1]; %lower and upper bound of the 5 parameters (a,b,c,d,m)
    nn=length(LB);   
    
    %using genetic algorithms (GA) to optimize the parameters
    pars=ga(@(pars)ObjFun_abcd_lump(pars,P0,PET0,Robs0,Inv0,TMIN0,BFI),nn,[],[],[],[],LB,UB);  
     

