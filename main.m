clc;clear;close all;
%%
% 本程序先考虑一天的数据，如果考虑多天，读入文件部分需要再修改
%% 
startFileNum = 201610010010;
endFileNum = 201610010835;
interval = 5;
trainingCount = 25;
testingCount = 1;

trainingGs = [];
testingGs = [];
% splitFlag = 5; % 分割训练数据和测试数据
% trainingSampleCounts = splitFlag;

errs_prediction_mase=[];
errs_average_mase=[];

%% init data

for i=1:trainingCount
    currFileNum = startFileNum+i*interval;
    if(rem(currFileNum,100)>55)
        continue; % 文件名为非连续；日和月也需要修改
    end
    [trainingGs(i,:,:),trainingYs(i,:,:)] = preProcess(currFileNum);
end
% 此处只将下一个时间片作为测试案例
[testingGs(1,:,:),testingYs(1,:,:)]=preProcess(currFileNum);
[err_prediction_mase,err_average_mase]=process(trainingGs,trainingYs,testingGs,testingYs);
errs_prediction_mase=[errs_prediction_mase,err_prediction_mase];
errs_average_mase=[errs_average_mase,err_average_mase];
%% Flow：流的形式进行更新训练集和测试集

for i=currFileNum:interval:endFileNum-1*interval % 此处减去1是为了留出一个测试案例
    if(rem(i,100)>55)
        continue; % 文件名为非连续
    end
    trainingGs = trainingGs(2:end,:,:);
    trainingYs = trainingYs(2:end,:,:);
    [trainingGs(trainingCount,:,:),trainingYs(trainingCount,:,:)] = preProcess(i);
    [testingGs(1,:,:),testingYs(1,:,:)]=preProcess(i);
    [err_prediction_mase,err_average_mase]=process(trainingGs,trainingYs,testingGs,testingYs);
    errs_prediction_mase=[errs_prediction_mase,err_prediction_mase];
    errs_average_mase=[errs_average_mase,err_average_mase];
end

%% 可视化
figure;
plot(errs_prediction_mase,'b');
hold on;
plot(errs_average_mase,'r');
legend('lsm-rn错误率','平均值错误率')



