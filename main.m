clc;clear;close all;
%%
% 本程序先考虑一天的数据，如果考虑多天，读入文件部分需要再修改
%% 
startFileNum = 201709100910;
endFileNum = 201709101045;
interval = 5;
trainingCount = 12;
testingCount = 1;

trainingGs = [];
testingGs = [];

% 用于收集各项指标的数组
errs_prediction_mape=[];
errs_average_mape=[];

errs_prediction_mae=[];
errs_average_mae=[];

errs_prediction_rmse=[];
errs_average_rmse=[];

errs_prediction_nmae=[];
errs_average_nmae=[];

%% init data
currFileNum = startFileNum;
for i=1:trainingCount
    if(rem(currFileNum,100)>55)
        continue; % 文件名为非连续；日和月也需要修改
    end
    [trainingGs(i,:,:),trainingYs(i,:,:)] = preProcess(currFileNum);
    currFileNum = nextFileNum(currFileNum,interval);
end

% 此处只将下一个时间片作为测试案例
[testingGs(1,:,:),testingYs(1,:,:)]=preProcess(currFileNum); %当前currFileNum 刚好是训练数据的下一个。

% 获得各项指标
[err_prediction_mape,err_average_mape,err_prediction_mae,err_average_mae,...
err_prediction_rmse,err_average_rmse,err_prediction_nmae,err_average_nmae]=process(trainingGs,trainingYs,testingGs,testingYs);

errs_prediction_mape=[errs_prediction_mape,err_prediction_mape];
errs_average_mape=[errs_average_mape,err_average_mape];

errs_prediction_mae=[errs_prediction_mae,err_prediction_mae];
errs_average_mae=[errs_average_mae,err_average_mae];

errs_prediction_rmse=[errs_prediction_rmse,err_prediction_rmse];
errs_average_rmse=[errs_average_rmse,err_average_rmse];

errs_prediction_nmae=[errs_prediction_nmae,err_prediction_nmae];
errs_average_nmae=[errs_average_nmae,err_average_nmae];

%% Flow：流的形式进行更新训练集和测试集

while currFileNum<endFileNum % 留出一个测试案例，如果测试多步，则需要更改
    
    % 将训练数据整体向前移动一位，并将新的一行添加至尾部
    trainingGs = trainingGs(2:end,:,:);
    trainingYs = trainingYs(2:end,:,:);
    
    [trainingGs(trainingCount,:,:),trainingYs(trainingCount,:,:)] = preProcess(currFileNum);
    [testingGs(1,:,:),testingYs(1,:,:)]=preProcess(nextFileNum(currFileNum,interval)); %当前测试数据的坐标
    currFileNum=nextFileNum(currFileNum,interval);
    
    %% 收集各项指标
    
    [err_prediction_mape,err_average_mape,err_prediction_mae,err_average_mae,...
    err_prediction_rmse,err_average_rmse,err_prediction_nmae,err_average_nmae]=process(trainingGs,trainingYs,testingGs,testingYs);
    
    errs_prediction_mape=[errs_prediction_mape,err_prediction_mape];
    errs_average_mape=[errs_average_mape,err_average_mape];
    
    errs_prediction_mae=[errs_prediction_mae,err_prediction_mae];
    errs_average_mae=[errs_average_mae,err_average_mae];
    
    errs_prediction_rmse=[errs_prediction_rmse,err_prediction_rmse];
    errs_average_rmse=[errs_average_rmse,err_average_rmse];
    
    errs_prediction_nmae=[errs_prediction_nmae,err_prediction_nmae];
    errs_average_nmae=[errs_average_nmae,err_average_nmae];
end

%% 可视化
figure;
plot(errs_prediction_mape,'b');
hold on;
plot(errs_average_mape,'r');
legend('lsm-rn错误率','平均值错误率')
title('mape');



