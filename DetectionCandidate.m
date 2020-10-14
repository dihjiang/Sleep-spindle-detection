function detvec = DetectionCandidate(teo, tmin, threshold, baseline, fs)

% find peaks of teager energy output
[peaks,locs,width] = findpeaks(teo,1:length(teo),'MinPeakDistance',tmin*fs,...
    'MinPeakHeight',threshold);
% Start detection
begin_det = locs;
stop_det = locs;
% Only teo outputs exceeding baseline are considered for detection windows.
while any(teo(begin_det)>=baseline) || any(teo(stop_det)>=baseline)
    idx1 = find((teo(begin_det)>=baseline)==1);
    idx2 = find((teo(stop_det)>=baseline)==1);
    
    idx1 = idx1(find(begin_det(idx1) > 1));
    idx2 = idx2(find(stop_det(idx2) < length(teo)));
    
    if isempty(idx1) && isempty(idx2)
        break;
    end
    
    begin_det(idx1) = begin_det(idx1) - 1;
    stop_det(idx2) = stop_det(idx2) + 1;
end

% Generating preliminary detection windows
detvec = zeros(length(teo),1);
for ii = 1 : length(begin_det)
    detvec(begin_det(ii):stop_det(ii))=1;
end

end