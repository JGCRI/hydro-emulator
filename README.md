### Hydrological Emulator (HE) - Version 1

#### NOTICE
This repository uses Git Large File Storage (LFS).  Please run the following before cloning this repository:  **git lfs install**

#### About


#### Reference


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
