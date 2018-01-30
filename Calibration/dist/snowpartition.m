function [RAIN,SNOW] = snowpartition(TOTAL,TMIN,Tsnow,Train)
%TOTAL: total precipitation
%TMIN: minimum air temperature
%Tsnow: temperature threshold below which all precipitation falls as snow 
%Train: temperature threshold above which all precipitation falls as rainfall 
   SNOW=zeros(size(TOTAL));
   RAIN=zeros(size(TOTAL));
    
  [allrain]    = find(TMIN > Train);
  [rainorsnow] = find(TMIN <= Train & TMIN >= Tsnow);
  [allsnow]    = find( TMIN < Tsnow);

  SNOW(rainorsnow) = TOTAL(rainorsnow).*((Train - TMIN(rainorsnow)))/(Train - Tsnow);

if (allrain)
   RAIN(allrain) = TOTAL(allrain);
   SNOW(allrain) = 0;
end

if (rainorsnow)
   RAIN(rainorsnow) = TOTAL(rainorsnow) - SNOW(rainorsnow);
end

if (allsnow)
   RAIN(allsnow) = 0;
   SNOW(allsnow) = TOTAL(allsnow);
end


