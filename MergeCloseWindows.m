function detvec = MergeCloseWindows(detvec, tgap, fs)

% Get the beginning and end points of all detection windows
begin_det = find(diff([0;detvec])==1);
stop_det = find(diff([detvec;0])==-1);

% Merge too close windows
detvec_gap = begin_det(2:end) - stop_det(1:end-1); 
merge_pos = find(detvec_gap < round(tgap * fs));
for kk = 1 : length(merge_pos)
    detvec(stop_det(merge_pos(kk))+1 : begin_det(merge_pos(kk)+1)-1) = 1;
end

end