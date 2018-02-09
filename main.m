clc;clear;close all;

%% 
startFileNum = 201610010810;
endFileNum = 201610010920;
interval = 5;

trainingGs = [];
testingGs = [];
splitFlag = 5; % �ָ�ѵ�����ݺͲ�������
trainingSampleCounts = splitFlag;

%% read data
i=startFileNum;
counter=1;
while(i<=endFileNum)
    snapshots(counter,:,:)=load(['.\data\' num2str(i) 'out.txt']);
    if(rem(i,100)==55)
        i = i + 40; % ����Сʱ+1��
    end
    counter=counter+1;
    i=i+interval;
end

trainingGs = snapshots(1:splitFlag,:,:);
testingGs = snapshots(splitFlag+1:end,:,:);

%% params

size= size(snapshots);
T=size(1);
n=size(2);
testingSampleCounts = T-trainingSampleCounts;
k=30;
iter =2000;
threshold = 10;
lambda = 2;
gamma = 2;
threshold = 0.01;

%% prepare W, D, L ,Ys, Us, B, A

W=zeros(n,n);
for i=2:n
    W(i-1,i)=1;
end

D=zeros(n,n);
for i=1:n
    D(i,i)=sum(W(:,i));
end

L=D-W;

for i=1:trainingSampleCounts
    trainingYs(i,:,:)=zeros(n,n);
    trainingYs(i,find(trainingGs(i,:,:)>0))=1;
end

B = rand(k,k);
A = rand(k,k);
for i=1:trainingSampleCounts
    trainingUs(i,:,:) = rand(n,k);
end
%% training
preGoalValue = 1e10;
values=[];
for i=1:iter 
    goalvalue = goalValue(trainingYs,trainingGs,trainingUs,B,L,A,lambda,gamma)
    values = [values goalvalue];
%     if(abs(goalvalue-preGoalValue)<threshold) 
%         break;
%     end
    preGoalValue=goalvalue;
    [trainingUs,B,A]=globalLearning(trainingYs,trainingGs,trainingUs,B,W,D,A,lambda,gamma);
end

plot(values);
figure;

%% evaluation completion

err=0;
for i=2:trainingSampleCounts-1
    completion = squeeze(trainingUs(i,:,:))*B*squeeze(trainingUs(i,:,:))';
    tmp = abs(squeeze(trainingGs(i,:,:))-completion)./squeeze(trainingGs(i,:,:));
    tmp(find(squeeze(trainingGs(i,:,:))==0))=0;
    
    speed_completion = 0;
    speed_base = 0;


    for j=2:n
        speed_completion = [speed_completion completion(j,j-1)];
        speed_base = [speed_base trainingGs(i,j,j-1)];
    end

%     plot(speed_completion)
%     title(['��ȫ' num2str(i)]);
%     figure;
% 
%     plot(speed_base);
%     title(['ʵ��ֵ' num2str(i)]);
%     figure;

    err = err + sum(sum(tmp));
    
end
completion_err = err/((trainingSampleCounts-2)*sum(sum(D)))

%% prediction 
prediction = squeeze(trainingUs(splitFlag-1,:,:))*A*A*B*(squeeze(trainingUs(splitFlag-1,:,:))*A*A)';
average = squeeze(mean(trainingGs));

speed_prediction =[];
speed_base =[];
speed_average=[];
for j=2:n
    speed_prediction = [speed_prediction prediction(j,j-1)];
    speed_base = [speed_base testingGs(1,j,j-1)];
    speed_average=[speed_average average(j,j-1)];
end

plot(speed_completion)
hold on;
plot(speed_base,'g');
hold on;
plot(speed_average,'r')
legend('Ԥ��ֵ','ʵ��ֵ','ƽ��ֵ');
figure;

tmp = abs(squeeze(testingGs(1,:,:))-prediction)./squeeze(testingGs(1,:,:));
tmp(find(squeeze(testingGs(1,:,:))==0))=0;

prediction_err = sum(sum(tmp))/(sum(sum(D)))


tmp = abs(squeeze(testingGs(1,:,:))-average)./squeeze(testingGs(1,:,:));
tmp(find(squeeze(testingGs(1,:,:))==0))=0;

average_err = sum(sum(tmp))/(sum(sum(D)))
%% visualization

% speed_completion = 0;
% speed_base = 0;
% for i=2:n
%     speed_completion = [speed_completion completion(i,i-1)];
%     speed_base = [speed_base Gs(4,i,i-1)];
% end
% plot(speed_completion);
% figure;
% plot(speed_base,'r')
% figure;
% plot(values);

