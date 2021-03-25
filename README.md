# Sleep-spindle-detection
## This repo corresponds to the following article:
Jiang, D., Ma, Y., & Wang, Y. (2021). A robust two-stage sleep spindle detection approach using single-channel EEG. Journal of Neural Engineering, 18(2), 026026. https://dx.doi.org/10.1088/1741-2552/abd463

# Description
## main function
SpindleDetection.m is the main function for detecting spindles.  

(It can be easily adapted under different settings, e.g. different datasets, different ground truth).

## Data preparation (how data and annotations are stored and loaded)
Extract N2 EEG from original EDF format, and store them in one mat file. 
In this repo, the mat file to be loaded only has one variable, i.e. eeg_N2 (a 1 x 15 cell variable, where each index refers to one patient).
For i = 1, 2, ..., 15, eeg_N2{i} contains two columns: 
first column is raw N2 EEG signal, the second column is spindle annotation (a binary vector). Two columns are in equal-length. When data is ready, run SpindleDetection.m directly.

Since I do not have redistribution permission of MASS dataset, one can refer to the following reference and contact the author for dataset access if needed:
O'reilly, Christian, Nadia Gosselin, Julie Carrier, and Tore Nielsen. "Montreal Archive of Sleep Studies: an open‐access resource for instrument benchmarking and exploratory research." Journal of sleep research 23, no. 6 (2014): 628-635
