function [PFD] = Petrosian_FD(serie)
%{
Script for computing the Katz Fractal Dimension (PFD).

INPUT:
    serie: is the temporal series(matrix) that one wants to analyze by PFD.
    (size: nPoints_of_Epoch * nEpochs)
  

OUTPUT:
    PFD: the PFD of the temporal series.

TIP: the PFD of a straight line must be exactly 1. Otherwise, the
implementation of the algorithm is wrong. 
    Actually, there are 5 methods to convert serie into a binary sequence.
    Here I choose method c ('differential method')
Ref: A. Petrosian, ¡°Kolmogorov complexity of finite sequences and recognition of different preictal EEG patterns,¡±,
     Proc. Eighth IEEE Symp. Comput. Med. Syst., pp. 212¨C217, 1995. 

PROJECT: Research Master in EEG analysis  - Fudan University

DATE: 24/01/2018

AUTHOR: Jiang Dihong
%}

N = size(serie,1);  % number of points in an epoch
M = zeros(1,size(serie,2));     % Initialization of M, which refers to number of sign changes in sdf.
sdf = diff(serie);  % get differential results
% binarization by using method c
for i = 1:size(serie,2)
    sdf(find(sdf(:,i)>0),i)=1; 
    sdf(find(sdf(:,i)<=0),i)=-1;
    sddf = diff(sdf);
    M(i) = length(find(sddf(:,i)~=0)); % calculate M
end

% calculate PFD
PFD = log(N)./(log(N) + log(N./(N+0.4*M)));