%% pre-processing:
clc
clear 
clear all
close all

%% Add paths of functions:
addpath('functions');
addpath('functions_PCA');
addpath('functions_LBP');

%% Setting path of input images:
PathName='.\Datasets\1_FEI_resized\';
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);
[~,order] = sort_nat({imglist.name});
imglist = imglist(order);  % imglist is now sorted

%% Local Binary Pattern:
disp('Applying Local Binary Pattern...');
Males_train_data = [];
Females_train_data = [];
Males_test_data = [];
Females_test_data = [];
for i = 1:imgnum
    FileName = imglist(i).name;
    Image = imread([PathName,FileName]);
    Image = double(Image);
    LBP_type = 'uniform_LBP';   %---> 'simple_LBP' or 'uniform_LBP'
    feature_vector = LBP(Image, LBP_type);
    if i >= 1 && i<= 75 
        Males_train_data(end+1,:) = feature_vector;
    elseif i >= 76 && i<= 100
        Males_test_data(end+1,:) = feature_vector;
    elseif i >= 1+100 && i<= 75+100
        Females_train_data(end+1,:) = feature_vector;
    elseif i >= 76+100 && i<= 200
        Females_test_data(end+1,:) = feature_vector;
    end
end
training_labels = [-1*ones(size(Males_train_data,1),1); 1*ones(size(Females_train_data,1),1)];

%% PCA:
disp('Applying PCA on train (training PCA)...');
input_train = [Males_train_data; Females_train_data];
egnPow = 0.9999;
[ egnVct , egnValSort , meanV ] = PCA(input_train, egnPow);
input_train = input_train * egnVct;

%% Trianing Backpropagation neural network:
disp('Training Back Propagation Neural Network...');
trainInputs = input_train';   %---> every colomn is as a training sample  %--> 150 samples with 148 dimension (148 input neuron)
target = training_labels'; %---> -1: means male , 1: means female
net = newff(trainInputs,target,[10],{},'traingd');  % newff is the toolbox of MATLAB for Neural Network training
net.trainParam.show = 50;
net.trainParam.lr = 0.05;
net.trainParam.max_fail = 10000;
net.trainParam.epochs = 5000;                      % it is important: "Max number of iterations (wight updates)" ---> default: 1000
net.trainParam.goal = 1e-20;                        % it is important: "Max Error" to reach ---> default: 0
[net,tr] = train(net,trainInputs,target);            % it is the function of training: trains the network

%% PCA on test:
disp('Applying PCA on test...');
input_test = [Males_test_data; Females_test_data];
egnPow = 0.9999;
input_test = input_test * egnVct;
testInputs = input_test';   %---> every colomn is as a training sample  %--> 50 samples with 148 dimension (148 input neuron)

%% Testing Neural Network:
disp('Testing Back Propagation Neural Network...');
outputTrainTest = sim(net,testInputs); %simulation function for testing NN ---> net: NN, trainInputs: input to be tested, outputTest: output of test

%% Report rates:
outputTrainTest(outputTrainTest < 0) = -1;
outputTrainTest(outputTrainTest >= 0) = 1;
recognized_labels_males = outputTrainTest(1:length(outputTrainTest)/2)';
recognized_labels_females = outputTrainTest(length(outputTrainTest)/2 + 1 : end)';
recognized_labels = [recognized_labels_males, recognized_labels_females];  %--> column 1: test males, column 2: test females | -1 means recognizing male, 1 means recognizing female
rate = (sum(recognized_labels(:,1) == -1) + sum(recognized_labels(:,2) == 1)) / (size(recognized_labels,1) * size(recognized_labels,2));
rate_male_tests = sum(recognized_labels_males(:,1) == -1) / length(recognized_labels_males);
rate_female_tests = sum(recognized_labels_females(:,1) == 1) / length(recognized_labels_females);
disp('Recognition rate:');
disp(rate);
disp('Recognition rate of males:');
disp(rate_male_tests);
disp('Recognition rate of females:');
disp(rate_female_tests);

%% save results:
cd('saved_results');
save recognized_labels_males.mat recognized_labels_males
save recognized_labels_females.mat recognized_labels_females
save recognized_labels.mat recognized_labels
save rate.mat rate
save rate_male_tests.mat rate_male_tests
save rate_female_tests.mat rate_female_tests
cd('..');

