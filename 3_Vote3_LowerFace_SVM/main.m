%% pre-processing:
clc
clear 
clear all
close all

%% Add paths of functions:
addpath('functions');

%% Setting path of input images:
PathName='.\Datasets\FEI_lowerFace_resized\';
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);
[~,order] = sort_nat({imglist.name});
imglist = imglist(order);  % imglist is now sorted

%% Preparing data for SVM:
disp('Preparing data for SVM...');
Males_train_data = [];
Females_train_data = [];
Males_test_data = [];
Females_test_data = [];
PathName2 = '.\Datasets\2_FEI_lowerFace\';
for i = 1:imgnum
    FileName = imglist(i).name;
    Image = imread([PathName,FileName]);
    Image = double(Image);
    if i >= 1 && i<= 75 
        Males_train_data(end+1,:) = reshape(Image, 1, []);
    elseif i >= 76 && i<= 100
        Males_test_data(end+1,:) = reshape(Image, 1, []);
    elseif i >= 1+100 && i<= 75+100
        Females_train_data(end+1,:) = reshape(Image, 1, []);
    elseif i >= 76+100 && i<= 200
        Females_test_data(end+1,:) = reshape(Image, 1, []);
    end
end

%% Train SVM:
disp('Training SVM...');
input = [Males_train_data; Females_train_data];
Y = [-1*ones(size(Males_train_data,1),1); 1*ones(size(Females_train_data,1),1)];
SVMModel = fitcsvm(input,Y,'KernelFunction','rbf','KernelScale','auto');

%% Test SVM:
disp('Testing SVM...');
[Yfit_males,scores_males] = predict(SVMModel, Males_test_data);
[Yfit_females,scores_females] = predict(SVMModel, Females_test_data);
recognized_labels = [Yfit_males, Yfit_females];  %--> column 1: test males, column 2: test females | -1 means recognizing male, 1 means recognizing female
recognized_labels_males = Yfit_males;
recognized_labels_females = Yfit_females;
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


