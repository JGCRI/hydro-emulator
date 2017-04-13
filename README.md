### Hydrological Emulator (HE) - Version 1

#### NOTICE
This repository uses Git Large File Storage (LFS).  Please run the following before cloning this repository:  **git lfs install**

#### About
The hydrological emulator was built upon the monthly “abcd” model, which was first introduced to improve the national water assessment for the U.S., with a simple analytical framework using only a few descriptive parameters. The model uses potential evapotranspiration (PET) and precipitation (P) as input. The model defines four parameters a, b, c, and d that reflect regime characteristics to simulate water fluxes (e.g., evapotranspiration, runoff, groundwater recharge) and pools (e.g., soil moisture, groundwater). The parameters a and b pertain to runoff characteristics, and c and d relate to groundwater. Specifically, the parameter a reflects the propensity of runoff to occur before the soil is fully saturated. The parameter b is an upper limit on the sum of evapotranspiration (ET) and soil moisture storage. The parameter c indicates the degree of recharge to groundwater and is related to the fraction of mean runoff that arises from groundwater discharge. The parameter d is the release rate of groundwater to baseflow, and thus the reciprocal of d is the groundwater residence time. Snow is not part of the original “abcd” model, here we leverage the work of Martinez and Gupta (2010) which added snow processes into the original “abcd” model, where the snowpack accumulation and snow melt are estimated based on air temperature.  

We adopt the “abcd” framework from Martinez and Gupta (2010); meanwhile, we make three modifications. First, instead of involving three snow parameters in the parameterization process, we adapt parameter values for two of the parameters (i.e., temperature threshold above or below which all precipitation falls as rainfall or snow) from literature and only keep a tunable parameter m – snow melt coefficient (0 < m < 1), in order to enhance the model efficiency with as least necessary parameters as possible. Second, we introduce the baseflow index (BFI) into the parameterization process to improve the partition of total runoff between the direct runoff and baseflow. Third, other than the lumped scheme as previous studies used, we first explore the values of model application in distributed scheme with a grid resolution of 0.5 degree. The detailed model descriptions and equations are presented in Liu et al. (in review). 


#### Reference
Liu, Y., Hejazi, M.I., Li, H., Zhang, X., Leng, G., A Hydrological Emulator for Global Applications, Geoscientific Model Development (in review)
Martinez, G.F., Gupta, H.V., 2010. Toward improved identification of hydrological models: A diagnostic evaluation of the “abcd” monthly water balance model for the conterminous United States. Water Resources Research, 46(8).


#### Content
1. The HE source code includes 5 main files:
* __ABCD_noconstrain.m__, this file presents the main model frame, and it takes climate input and yields output of runoff, ET, soil moisture, groundwater recharge and etc. “noconstrain” here stands for it does not have constrain for the groundwater pool.
* __snowpartition.m__, this file is used to partition precipitation between rainfall and snow according to temperature threshold, and it is called by the ABCD_noconstrain.m.
* __ObjFun_ABCD_lump.m__, (or ObjFun_ABCD_dist.m), this file contains the objective function of the calibration. During the calibration process, the HE tries to minimize the objective function to get optimized parameters.
* __KGE.m__, this file is used to calculate kling-gupta efficiency, which is a metric used to measure the predictability of a model.
* __Calibration_lump.m__, (or Calibration_dist.m), this file is used to calibrate the HE to get basin-specific parameters.  
2. All HE input data is saved in the folder “watch_basin_data”, which includes 235 files for 235 global basins. For each file, the basin-specific gridded-level climate inputs, such as monthly precipitation (P), minimum air temperature (TMIN), potential evapotranspiration (PET), observed runoff (Robs, actually here we use VIC runoff product) and baseflow index (BFI), are included. The spatial resolution is 0.5-degree and it is monthly data.  
3. The HE includes a distributed (dist) and a lumped (lump) scheme. The difference between these two schemes is: the lumped one treats one basin as a grid and all the gridded climate inputs are averaged to basin-average as input to the HE; in distributed one, model simulation is conducted at each 0.5-degree grid, and each grid has its own input and output. Both schemes yield a set of basin-specific parameters.  
4. All output data from the calibration process is saved in the folder of “lump” (or “dist”) as the form of “Cal_lump_noconstrain_basin_*.mat” (or Cal_dist_noconstrain_basin_*.mat), where the values of the optimized parameters, KGE, basin id, model input and output variables are included.  
5. For further questions, please contact Dr. Yaling Liu ([yaling.liu@pnnl.gov](yaling.liu@pnnl.gov)) or [cauliuyaling@gmail.com](cauliuyaling@gmail.com)).
