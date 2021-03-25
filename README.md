# Sleep-spindle-detection
## This repo corresponds to the following article:
Jiang, D., Ma, Y., & Wang, Y. (2021). A robust two-stage sleep spindle detection approach using single-channel EEG. Journal of Neural Engineering, 18(2), 026026. https://dx.doi.org/10.1088/1741-2552/abd463

# Description
## Main function
**SpindleDetection.m** is the main function for detecting spindles.  

It can be easily adapted under different settings, e.g. different datasets, different ground truth.

## Data preparation (how data and annotations are stored and loaded)
Extract N2 EEG from original EDF format, and store them in one mat file. 
In this repo, the mat file to be loaded only has one variable, i.e. eeg_N2 (a 1 x 15 cell variable, where each index refers to one patient).  

For i = 1, 2, ..., 15, eeg_N2{i} contains two columns: 
* The first column is raw N2 EEG signal
* The second column is a binary vector that represents spindle annotation. It can be generated based on annotation file.

Two columns are in equal-length. When data is ready, run **SpindleDetection.m** directly.


Since I do not have redistribution permission of MASS dataset, one can refer to the following reference and contact the author for dataset access if needed:  

O'reilly, C., Gosselin, N., Carrier, J., & Nielsen, T. (2014). Montreal Archive of Sleep Studies: an open‐access resource for instrument benchmarking and exploratory research. Journal of sleep research, 23(6), 628-635. https://doi.org/10.1111/jsr.12169
