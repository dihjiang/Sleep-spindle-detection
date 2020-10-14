function LRMSV = LogRootMeanSeqVar(x)
%{
    Script for computing the Log root mean of sequential variations (LRSSV).

INPUT:
    x: is the temporal series (matrix) that one wants to analyze by LRSSV.
    (size: nPoints_of_Epoch * nEpochs)
  

OUTPUT:
    LRSSV: the LRSSV of the temporal series (matrix).


PROJECT: Research Master in EEG analysis  - Fudan University

DATE: 10/07/2019

AUTHOR: Jiang Dihong

%}



LRMSV = log10(sqrt(mean(diff(x).^2)));

end