function [err_prediction_mase,err_average_mase]=evaluation(prediction,base,average)
[n,n]=size(prediction);

%% mape
err_prediction_mase = mape(prediction,base);
err_average_mase = mape(prediction,base);

%% mae
err_prediction_mae=mae(prediction,base);
err_average_mae = mae(prediction,base);

% average
err_average_matrix = abs(average-base)./base;
err_average_matrix(find(base==0))=0;
err_average_mase = sum(sum(err_average_matrix))*1.0/validCount

%% visualization

prediction_element=[];
base_element=[];
average_element=[];

for i=1:n-1;
    prediction_element =[prediction_element,prediction(i+1,i)];
    base_element =[base_element,base(i+1,i)];
    average_element =[average_element,average(i+1,i)];
end

% figure;
% plot(prediction_element);
% hold on;
% plot(base_element,'r');
% hold on;
% plot(average_element,'y');
% legend('预测值','实际值','平均值');
% xlabel('路段编号') % x-axis label
% ylabel('路段相对流量值') % y-axis label

