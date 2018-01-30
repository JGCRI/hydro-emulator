function [Rsim,Ea, G, S,RE,DR,base,XS,RAIN,SNOW,SNM]=abcd(pars,P,PET,Inv,TMIN)
% Reference:
% Martinez, G. F., & Gupta, H. V. (2010). Toward improved identification 
% of hydrological models: A diagnostic evaluation of the ¡°abcd¡± monthly 
% water balance model for the conterminous United States. Water Resources Research, 46(8).
%-----------------------------------------Input and output information
% pars: model parameters,including four parameters that are a,b,c and d repectively
% P and PET are monthly precipitation and potential evapotranspiration respectively
% Inv is the initial values
% Rsim are Ea are simulated streamflow and actual evapotranspiration respectively

%%
a=pars(1); %0-1
b=pars(2)*1000; %100-1000 mm
c=pars(3);%0-1
d=pars(4); % 0-1
m=pars(5);%0-1

SNM=zeros(size(P));%snowmelt
Ea=zeros(size(P));%actual ET
Rsim=zeros(size(P));%simulated runoff
RE=zeros(size(P));%groundwater recharge
DR=zeros(size(P));%direct runoff
base=zeros(size(P));%groundwater discharge, that is baseflow
G=zeros(size(P));%groundwater storage
S=zeros(size(P));%soil moisture storage
W=zeros(size(P));%%available water
Y=zeros(size(P));%ET opportunity
XS=zeros(size(P));%accumulated snow water equivalent (i.e., snowpack)
RAIN=zeros(size(P));
SNOW=zeros(size(P));
Ea(:,1)=P(:,1)*0.6;%initial value of actual ET

XS(:,1)=P(:,1)/10;%initial value of accumulated snow water equivalent is set to 10% of precipitation
SN0=0; %Initial Storage of Snow

Rsim(:,1)=repmat(Inv(1),size(Rsim,1),1);% initial steamflow
S0=Inv(2);% initial value for soil moisture storage
G0=Inv(3);%initial value for groundwater storage
Train=2.5;
Tsnow=0.6;

TOTAL=P;
[RAIN,SNOW] = snowpartition(TOTAL,TMIN,Tsnow,Train);   

%----------------------------------------------------
for i=1:size(P,2);  %number of months
    if i > 1
      XS(:,i) = XS(:,i-1) + SNOW(:,i);
   else
      XS(:,i) = SN0 + SNOW(:,i);     
   end
%Select only snow, intermediate or only rain for each case

      [allrain]    = find(TMIN(:,i) > Train);
      [rainorsnow] = find(TMIN(:,i) <= Train & TMIN(:,i) >= Tsnow);
      [allsnow]    = find( TMIN(:,i) < Tsnow);
      
%estimate snowmelt (SNM)
       SNM(allrain,i) = XS(allrain,i)*m;

       SNM(rainorsnow,i) = XS(rainorsnow,i)*m.*((Train - TMIN(rainorsnow,i)))/(Train - Tsnow);
  
       SNM(allsnow,i) =0;

   XS(:,i) = XS(:,i) - SNM(:,i);  %accumulated snow water equivalent             
     
   if i > 1
      W(:,i) = RAIN(:,i) + S(:,i-1) + SNM(:,i);  %available water
   elseif 1 == i
      W(:,i) = RAIN(:,i) + S0;                    
   end
        
   Y(:,i) = ((W(:,i)) + b)/(2*a)-power(power((W(:,i) + b)/(2*a),2) - (W(:,i))*b/a, 0.5 );   %ET opportunity
   S(:,i) = Y(:,i).*exp(-PET(:,i)/b);%soil water storage

   if i >1
      G(:,i) = (G(:,i-1)+c*(W(:,i)-Y(:,i)))/(1+d);
   elseif 1 == i
      G(:,i) = (G0+c*(W(:,i)-Y(:,i)))/(1+d);%groundwater storage
   end
   
    %%   
   Ea(:,i) = Y(:,i) - S(:,i);
   Ea(:,i)=max(0,Ea(:,i));  
   Ea(:,i)=min(PET(:,i),Ea(:,i));      
   S(:,i)=Y(:,i) -Ea(:,i); 
   RE(:,i) = c*(W(:,i)-Y(:,i));
   DR(:,i)=(1-c)*(W(:,i)-Y(:,i));
   Rsim(:,i) = (1-c)*(W(:,i)-Y(:,i))+d*G(:,i);
   base(:,i)=d*G(:,i);
  
end
