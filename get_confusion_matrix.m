function confusion_matrix = get_confusion_matrix(hyp,hyp_alg)
labels = unique(hyp);
num_labels = length(labels);
confusion_matrix = zeros(num_labels, num_labels);
% Éú³É»ìÏý¾ØÕó
for row = 1 : num_labels
    for arr = 1 : num_labels
        pos = find(hyp == labels(row));
        confusion_matrix(row, arr) = confusion_matrix(row, arr) + length(find(hyp_alg(pos) == labels(arr)));
    end
end

acc = mean(double(hyp_alg == hyp)) * 100;


