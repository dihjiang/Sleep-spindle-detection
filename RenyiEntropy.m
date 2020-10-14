function RE = RenyiEntropy(x,m,nbins)

%{
    Script for computing the Renyi Entropy (RE).

INPUT:
    x: is the temporal series (matrix) that one wants to analyze by RE.
    (size: nEpochs * nPoints_of_Epoch)
  

OUTPUT:
    RE: the RE of the temporal series (matrix).


PROJECT: Research Master in EEG analysis  - Fudan University

DATE: 10/07/2019

AUTHOR: Jiang Dihong

%}

% m is the order of RE, which should be greater than 0 and not equal to 1.
% m is 2 by default.

if nargin == 2
    nbins = 10;
elseif nargin == 1
    nbins = 10;
    m = 2;
end

RE = zeros(size(x,1),1);
% calculate the distribution of x. The default number of bins is 10.
for row = 1 : size(x,1)
    p = histcounts(x(row,:), nbins, 'Normalization', 'probability');
    RE(row) = 1/(1-m)*log2(sum(p.^m));
end

end