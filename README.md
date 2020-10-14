# Sleep-spindle-detection
This project corresponds to the following article:

SpindleDetection.m is the main function for detecting spindles of MASS dataset (with the union of both experts as the ground truth. It is similar with other settings, e.g. different datasets, different ground truth).

Data: Extract N2 EEG from original .EDF format, and store them in one variable (named as eeg_N2) in .mat format. eeg_N2 is a (15 * 1) cell variable (because a total of 15 subjects annotated by both experts are analysed in this work). For i = 1... 15, eeg_N2{i} contains two columns: first column is raw N2 EEG signal, the second column is spindle annotation (a binary vector). Two columns are in equal-length. When data is ready, run SpindleDetection.m directly.

Raw data file is not uploaded here, since I did not get permission from the author for redistribution. One can refer to the following reference and contact the author if needed:
O'reilly, Christian, Nadia Gosselin, Julie Carrier, and Tore Nielsen. "Montreal Archive of Sleep Studies: an open‐access resource for instrument benchmarking and exploratory research." Journal of sleep research 23, no. 6 (2014): 628-635
