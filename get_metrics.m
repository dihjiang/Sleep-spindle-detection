function confusion_matrix = get_metrics(confusion_matrix)
num_labels = size(confusion_matrix,1);
confusion_matrix = [confusion_matrix zeros(num_labels,2)];
confusion_matrix = [confusion_matrix;zeros(2,num_labels+2)];
num_of_correct = 0;
num_of_all = sum(sum(confusion_matrix(1:num_labels,1:num_labels)));
pe = 0;
for row = 1 : num_labels
    % 第num_labels + 1行每类的是查全率Recall
    confusion_matrix(row,num_labels + 1) = confusion_matrix(row,row) / sum(confusion_matrix(row, 1:num_labels));

    % 每列末尾是查准率Precision
    confusion_matrix(num_labels + 1,row) = confusion_matrix(row,row) / sum(confusion_matrix(1:num_labels, row));
    
    % 第num_labels + 2行是每类的F1-score
    confusion_matrix(num_labels + 2,row) = 2 * confusion_matrix(num_labels + 1,row) * confusion_matrix(row, num_labels + 1) / (confusion_matrix(num_labels + 1,row) + confusion_matrix(row, num_labels + 1));
    num_of_correct = num_of_correct + confusion_matrix(row,row);
    
    % weighted F1-score
    confusion_matrix(num_labels + 2,num_labels + 2) = confusion_matrix(num_labels + 2,num_labels + 2) + sum(confusion_matrix(row,1:num_labels))/num_of_all * confusion_matrix(num_labels + 2,row);
    
    pe = pe + sum(confusion_matrix(1:num_labels,row))*sum(confusion_matrix(row,1:num_labels))/num_of_all^2;
end
    
% 右下角是总Accuracy/ 总Recall (Weighted recall)
confusion_matrix(num_labels + 1,num_labels + 1) = num_of_correct / sum(sum(confusion_matrix(1:num_labels,1:num_labels)));

% Kappa conefficient
confusion_matrix(num_labels + 2,num_labels + 1) = (confusion_matrix(num_labels + 1,num_labels + 1) - pe)/(1 - pe);