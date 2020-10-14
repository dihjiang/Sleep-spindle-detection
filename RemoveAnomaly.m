function [eeg, spindle] = RemoveAnomaly(eeg, spindle, anomaly_eeg_th, anomaly_cali_th)

% This function is not part of the detection method, but it is necessary
% here because we concatenate all N2 EEG together. The difference
% between the last point of previous N2 segment and the first point of the
% next N2 segment might be huge, which may lead to a peak in TEO (of course
% this is undesirable). So this function searchs for difference larger than
% anomaly_eeg_th, and find the nearest point with difference below
% anomaly_cali_th, then remove EEG and spindle labels between them. This
% process will not impact the final detection, because sleep spindles are
% not likely to occur at the edge (either beginning or end) of N2 stage.

% Remove anomalous EEG and corresponding spindle labels
% difference between neighboring points larger than threshold are regarded as anomaly EEG
e_diff = diff([eeg;0]);
e_diff_abn = find(abs(e_diff) >= anomaly_eeg_th); % difference between neighboring sample points


jj = 1;
begin_abn = [];
stop_abn = [];
while jj < length(e_diff_abn)
    s = e_diff_abn(jj);
    idx = find(abs(eeg-eeg(s)) < anomaly_cali_th);
    e = idx(min(find(idx > s)));
    if isempty(e)
        break;
    end
    begin_abn = [begin_abn;s];
    stop_abn = [stop_abn;e];
    if e <= e_diff_abn(jj+1)
        jj = jj + 1;
    else
        jj = min(find(e_diff_abn >= e));
    end
end

for k = length(begin_abn) : -1 : 1
    eeg(begin_abn(k)+1:stop_abn(k)-1) = [];
    spindle(begin_abn(k)+1:stop_abn(k)-1) = [];
end

end