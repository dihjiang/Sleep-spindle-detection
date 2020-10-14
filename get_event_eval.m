function [eval, onset_diff] = get_event_eval(ground_truth, prediction, threshold)
% Output: onset_diff: onset difference compared to ground truth, here only
% matched spindles are considered.

    TP = 0;
    FN = 0; % spindle but is not detected
    FP = 0; % non-spindle but is detected as spindle
    
    % start-stop point of ground-truth windows
    begin_gt = find(diff([0;ground_truth])==1);
    stop_gt = find(diff([ground_truth;0])==-1);
    
    % start-stop point of predicted windows
    begin_pred = find(diff([0;prediction])==1);
    stop_pred = find(diff([prediction;0])==-1);
    
    % get TP, FN
    idx_previous = 0;
    onset_diff = [];
    for i = 1 : length(begin_gt)
        b_gt = begin_gt(i);
        s_gt = stop_gt(i);
        
        [~, idx] = min(abs(begin_pred(idx_previous+1:end) - b_gt));
        idx = idx + idx_previous;
        b_pred = begin_pred(idx);
        s_pred = stop_pred(idx);
        if isempty(b_pred)
            continue;
        end
        OvT = (min([s_gt,s_pred]) - max([b_gt,b_pred]))/(max([s_gt,s_pred]) - min([b_gt,b_pred]));
        if OvT >= threshold
            TP = TP + 1;
            onset_diff = [onset_diff;abs(b_gt - b_pred)];
%             idx_previous = idx;
        else
            FN = FN + 1;
        end
        
    end
    
    
    % get FP
    idx_previous = 0;
    for j = 1 : length(begin_pred)
        b_pred2 = begin_pred(j);
        s_pred2 = stop_pred(j);
        
        [~, idx] = min(abs(begin_gt(idx_previous+1:end) - b_pred2));
        idx = idx + idx_previous;
        b_gt2 = begin_gt(idx);
        s_gt2 = stop_gt(idx);
        OvT = (min([s_gt2,s_pred2]) - max([b_gt2,b_pred2]))/(max([s_gt2,s_pred2]) - min([b_gt2,b_pred2]));
%         if OvT >= threshold
%             idx_previous = idx;
%         else
%             FP = FP + 1;
%         end
        if OvT < threshold
            FP = FP + 1;
        end
    end
    
    eval.TP = TP;
    eval.FP = FP;
    eval.FN = FN;
    eval.recall = TP/(TP+FN);
    eval.precision = TP/(TP+FP);
    eval.F1 = 2*eval.recall*eval.precision/(eval.recall+eval.precision);

end