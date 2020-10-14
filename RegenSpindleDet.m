function detvec = RegenSpindleDet(detvec, tmin, tmax, tgap, fs)
% This function is to regenerate processed spindle detection windows, where
% too close windows are merged, too short windows are discarded, and too 
% long windows are cut down to max window length.

detvec = MergeCloseWindows(detvec, tgap, fs);

% Get the new merged windows
begin_det = find(diff([0;detvec])==1);
stop_det = find(diff([detvec;0])==-1);
locs = round((begin_det + stop_det)/2);

% Dection window with duration shorter than tmin are discarded.
det_discard = find((stop_det - begin_det) < tmin * fs);
begin_det(det_discard) = []; stop_det(det_discard) = []; locs(det_discard) = [];
% Dection window with duration larger than tmax are fixed to tmax, 
% with peak as the center, tmax as the duration.
det_toolong = find((stop_det - begin_det) > tmax * fs);
begin_det(det_toolong) = locs(det_toolong) - (tmax/2)*fs;
stop_det(det_toolong) = locs(det_toolong) + (tmax/2)*fs;

% Generate new candidate detection windows
detvec = zeros(length(detvec),1);
for ii = 1 : length(begin_det)
    detvec(begin_det(ii):stop_det(ii))=1;
end