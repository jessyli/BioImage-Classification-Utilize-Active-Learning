function [loss] = RegressionModel2()
% Implements a regression model
% Inputs: data - a 1000 by 25 matrix containing the data from 1000 patients.
%         labels - a 1 by 1000 vector containting the survival times for the patients
%         mode - a flag that determines which batch selection strategy is used. 1 = default selection mode; 2 = diverse label mode
% Outputs: loss a 1 by 90 vector that returns the generalization error as function of the number of rounds (90) 
load fisheriris
testdata = csvread('testSet.csv');
testdata = testdata([1:250],:);
data = [];
loss = [];
for i = 1:20
    data = [data; nextImage];
end
labels = load('trueLabels.mat');
labels=labels.trueLabels;
labeltrain = labels(1:20);
S0 = data;
% Factor = TreeBagger(50, S0, labeltrain);
Factor = fitcecoc(S0,labeltrain);
bt = 0.1;
for j = 21:5120
    temp = nextImage;
    
     [Predict_label,Scores] = predict(Factor, temp);
%     [Predict_label,NegLoss,PBScore] = predict(Factor,temp);
     [B,I]= sort(Scores);
    [B,I]= sort(abs(NegLoss));
    ptx = B(8);
    c1 = I(1);
    c2 = I(2);
    Uxi = (B(1)+B(2))/2;
    Lxi = B(8);
    lamda = 0.5;
    Qxt = bt*Uxi+(1-bt)*Lxi;
    if(Qxt>0.5)
        label=oracle2(temp);
        S0 = [S0; temp];
        labeltrain = [labeltrain, label];
         Factor = TreeBagger(50, S0, labeltrain);
%         Factor = fitcecoc(S0,labeltrain);
         [Predict_label,Scores] = predict(Factor, temp);
%         [Predict_label,NegLoss,PBScore] = predict(Factor,temp);
         [B,I]= sort(Scores);
%         [B,I]= sort(abs(NegLoss));
        pt1x = B(8);
        kl0 = ptx*log(ptx/pt1x);
        kl1 = pt1x*log(pt1x/ptx);
        kl = (kl1+kl0)/2;
        rt = kl;
        bt = max(min(bt*lamda*exp(rt),0.9),0.1);
    else
        S0 = S0;
    end
     [predictions1,testscore] = predict(Factor, testdata);
%     [predictions,NegLoss,PBScore] = predict(Factor,testdata);
     predictions = str2num(cell2mat(predictions1))';
    
    e = getTestError(predictions');
    e
    loss(j) = e;
end
plot(loss)

end
