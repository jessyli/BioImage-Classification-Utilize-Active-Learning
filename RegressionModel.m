function [loss] = RegressionModel()
% Implements a regression model
% Inputs: data - a 1000 by 25 matrix containing the data from 1000 patients.
%         labels - a 1 by 1000 vector containting the survival times for the patients
%         mode - a flag that determines which batch selection strategy is used. 1 = default selection mode; 2 = diverse label mode
% Outputs: loss a 1 by 90 vector that returns the generalization error as function of the number of rounds (90) 
load fisheriris
data = csvread('pool.csv');
labels = load('trueLabels.mat');
labels=labels.trueLabels;
datatrain = data([1:10],:);
labeltrain = labels(1:10);
% Factor = TreeBagger(500, datatrain, labeltrain);
datatest = data([11:5120],:);
labeltest = labels(11:5120);
labelnew = labels;
% [Predict_label,Scores] = predict(Factor, datatest);
% S = max(Scores, [], 2 );
% [B,I]= sort(S,'descend');
loss = [];
index1 = zeros(1, 5120);
for j = 1:511
     Factor = TreeBagger(500, datatrain, labeltrain,'OOBPred','On');
%     Mdl = fitcecoc(datatrain,labeltrain);
%     [Predict_label,NegLoss,PBScore] = predict(Mdl,datatest);
     [Predict_label,Scores] = predict(Factor, datatest);
    
     S = max(Scores, [], 2 );
%     S = max(NegLoss, [], 2 );
     predictlabel = str2num(cell2mat(Predict_label))';
%     labelnew(11:5120) = Predict_label;
     labelnew(11:5120) = predictlabel;
     [B,I]= sort(S,'descend');
%     [B,I]= sort(S);
    count = 1;
    
    for i = 1:10
        while(index1(I(count))==1)
            count = count+1;
        end
            index1(I(count)) = 1;
            index = I(count);
            datatrain = [datatrain; datatest(index,:)];
            labeltrain = [labeltrain, labeltest(index)];
        
    end
    e = getGeneralizationError(labelnew);
    e
    loss(j) = e;
end

plot(loss);
end
