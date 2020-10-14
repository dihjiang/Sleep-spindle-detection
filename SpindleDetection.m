clear;clc

load MASS_SS2_C3_N2Union
load train_val_test_split_E2


tic

% Initialization

% % for E1
% PatientID = [1:3 5:7 9:14 17:19]; 
% total_length = [[7413248,8965120,9411584,7169536,7998976,7421952,...
%     7245824,6873088,7638016,6638592,6511616,8072704,9312256,7213568,...
%     7453696,7255552,7256064,7566336,6756864]];

% for E2
PatientID = 1 : 15;                % E2  % Merged
total_length = [7413248,8965120,9411584,7998976,7421952,7245824,...
    7638016,6638592,6511616,8072704,9312256,7213568,7256064,7566336,6756864];



num_subject = length(PatientID);
num_features = 7;
lb = 8;% position of spindle labels
OvT = 0.2; % Overlap threshold for event-based evaluation

features = cell(num_subject,1);
detection = cell(num_subject,1);
duration = cell(num_subject,1);
density = zeros(num_subject,1);
onset_diff = cell(num_subject,1); % onset difference

acc_samp = zeros(num_subject,1);
sen_samp = zeros(num_subject,1);
spe_samp = zeros(num_subject,1);
kappa_samp = zeros(num_subject,1);
re_event = zeros(num_subject,1);
pr_event = zeros(num_subject,1);
f1_event = zeros(num_subject,1);
eval = cell(num_subject,1);


% The duration of the detection window must exceeds tmin but cannot be longer than tmax.
tmax = 3.0;
tmin = 0.3;
tgap = 0.15; % detection windows with time gap less than tgap are merged.


cm_det = zeros(2, 2);
cm_ml = zeros(2, 2);

TP = 0; FP = 0; FN = 0;
      
nLearn = 3;

% Initialization
fs = 256;
h_s = fir_kaiser(10.5,  11, 16, 16.5, fs);   % spindle filter

%% First stage: pre-detection
for i = PatientID
    fprintf('=========The %dth subject is being pre-detected========\n',i);
    eeg = eeg_N2{i}(:,1);     % N2 EEG
    spindle = eeg_N2{i}(:,2); % ground truth

    
    % scaling factors. Fine tuning on the first subject
    sf_range = (max(eeg)-min(eeg))/(265*2); % scaling factor for range

    
    
    anomaly_eeg_th = 200*sf_range; % Threshold for anomaly
    anomaly_cali_th = 50*sf_range; % Threshold for calibrating anomaly
    [eeg, spindle] = RemoveAnomaly(eeg, spindle, anomaly_eeg_th, anomaly_cali_th);

    % Spindle filtering
    eeg_s = conv(eeg,h_s,'same'); % bandpass filtering to obtain spindle component
    % Teager energy operator
    [~,teo_s] = energyop(eeg_s);
    
    % scaling factors. Fine tuning on the first subject
    sf_s = mean(abs(diff(eeg_s)))/0.8105; % scaling factor for difference

    baseline_spindle = 3*sf_s*sf_range; % baseline determines the begining and end point of detected spindles
    th_spindle = 7*sf_s*sf_range; % Only teo peaks exceeding threshold are considered as possible spindles.

    % Find spindle candidates and regenerate detection vector under certain rules
    detvec = DetectionCandidate(teo_s, tmin, th_spindle, baseline_spindle, fs);
    detvec = RegenSpindleDet(detvec, tmin, tmax, tgap, fs);        

    detection{i} = [detvec spindle]; % first col:detection vector; second col: ground truth

    % Find begining and end point of detected spindles
    begin_det = find(diff([0;detvec])==1);
    stop_det = find(diff([detvec;0])==-1);   
    
    % Feature extraction
    for j = 1 : length(begin_det)
        eeg_candidate = eeg_s(begin_det(j):stop_det(j));
        spindle_candidate = spindle(begin_det(j):stop_det(j));


        features{i}(j,1) = rms(eeg_candidate); % Root-mean-square
        features{i}(j,2) = RenyiEntropy(eeg_candidate');
        features{i}(j,3) = LogRootMeanSeqVar(eeg_candidate); 
        features{i}(j,4) = Petrosian_FD(eeg_candidate);
        features{i}(j,5) = KraskovEntropy(eeg_candidate,2);
        features{i}(j,6) = HjorthParameters(eeg_candidate);
        features{i}(j,7) = std(eeg_candidate);

        % generate spindle labels for all candidate segments
        if length(find(spindle_candidate==1)) >= 0.25*length(spindle_candidate)
            features{i}(j,8) = 1;
        else
            features{i}(j,8) = 0;
        end
        
        % Also store begining and end point of detected spindles, but they
        % will not be used in classification
        features{i}(j,9:10) = [begin_det(j) stop_det(j)]; 
    end       
    
    % feature normalization
    f = features{i}(:,1:7);
    f = mapminmax(f'); % mapped to [-1,1]
    features{i}(:,1:7) = f';
    
    toc

end

%% Second stage: refinement
for foldi = 1 : 5
    fprintf("==========Fold%d==========\n",foldi);
    % Subject-independent validation

    data_train = [];
    for j = trainID(foldi,:)
        data_train = [data_train;features{j}];
    end

    % trainig a bagging classifier 
    bag = fitensemble(data_train(:,1:num_features),data_train(:,lb),...
        'Bag',nLearn,'Discriminant','type','classification');

    % test begin
    for k = testID(foldi,:)
        fprintf('=========Subject %d is being tested==========\n',k);
        
        data_test = features{k};
        pred_test = predict(bag, data_test(:,1:num_features));
        
        % confusion matrix for machine learning
        cm_ml = cm_ml + get_confusion_matrix(data_test(:,lb),pred_test);
        fprintf('Accuracy_ml: %.2f%%\n',mean(double(data_test(:,lb) == pred_test)) * 100);
        
        % We only accept non-spindle identification to reduce false
        % detection rate
        non_spindle_begin = data_test(pred_test==0, lb+1);
        non_spindle_stop = data_test(pred_test==0, lb+2);

        for ii = 1 : length(non_spindle_begin)
            nsb = non_spindle_begin(ii);
            nss = non_spindle_stop(ii);
            detection{k}(nsb:nss,1) = 0;
        end

        % Get by-event evaluation
        eval{k} = get_event_eval(detection{k}(:,2), detection{k}(:,1), OvT);
        
        cm_per_sub = get_confusion_matrix(detection{k}(:,2),detection{k}(:,1));
        cm_det = cm_det + cm_per_sub;
        cm_per_sub = get_metrics(cm_per_sub);
        [eval{k}, onset_diff{k}] = get_event_eval(detection{k}(:,2), detection{k}(:,1), OvT);
        [duration{k},density(k)] = GetSpinChara(detection{k}(:,1), fs, total_length(i));

        re_event(k) = round(eval{k}.recall,3);
        pr_event(k) = round(eval{k}.precision,3);
        f1_event(k) = round(eval{k}.F1,3);
        acc_samp(k) = round(mean(detection{k}(:,2)==detection{k}(:,1)),3);
        sen_samp(k) = round(cm_per_sub(2,3),3);
        spe_samp(k) = round(cm_per_sub(1,3),3);
        kappa_samp(k) = round(cm_per_sub(4,3),3);

        fprintf('ACC: %.2f\n',acc_samp(k)*100);
        fprintf('SEN: %.2f\nSPE: %.2f\nKAPPA: %.2f\n',sen_samp(k)*100, spe_samp(k)*100,kappa_samp(k)*100);
        fprintf('RE: %.2f\nPR: %.2f\nF1: %.2f\n',re_event(k)*100,pr_event(k)*100,f1_event(k)*100);

        TP = TP + eval{k}.TP;
        FP = FP + eval{k}.FP;
        FN = FN + eval{k}.FN;
        toc
    end
end

cm_ml = get_metrics(cm_ml);

% confusion matrix of by-sample evaluation
cm_det = get_metrics(cm_det);

% overall: by-event evaluation result
overall.RE = TP /(TP + FN);
overall.PR = TP /(TP + FP);
overall.F1 = 2*overall.RE*overall.PR / (overall.RE + overall.PR);









