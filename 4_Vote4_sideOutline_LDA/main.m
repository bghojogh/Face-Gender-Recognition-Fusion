%% pre-processing:
clc
clear 
clear all
close all

%% Add paths of functions:
addpath('functions');
addpath('functions_LDA');

%% load data:
cd('saved_files');
load shape_t.mat
load number_of_landmarks.mat
cd('..');

%% Preparing data for LDA:
disp('Preparing data for LDA...');
Males_train_data = [];
Females_train_data = [];
Males_test_data = [];
Females_test_data = [];
total_number_of_persons = size(shape_t,1)/number_of_landmarks;
for i = 1:total_number_of_persons
    landmarks = shape_t((i-1)*number_of_landmarks + 1 : (i-1)*number_of_landmarks + number_of_landmarks, :);
    feature_vector = landmarks(1:17,:) - [mean(landmarks(:,1)) .* ones(17,1), mean(landmarks(:,2)) .* ones(17,1)];  %%% subtracting average of all landmarks from side-outline landmarks
    if i >= 1 && i<= 75 
        Males_train_data(end+1,:) = reshape(feature_vector, 1, []);
    elseif i >= 76 && i<= 100
        Males_test_data(end+1,:) = reshape(feature_vector, 1, []);
    elseif i >= 1+100 && i<= 75+100
        Females_train_data(end+1,:) = reshape(feature_vector, 1, []);
    elseif i >= 76+100 && i<= 200
        Females_test_data(end+1,:) = reshape(feature_vector, 1, []);
    end
end

%% Train LDA:
disp('Training LDA...');
input = [Males_train_data; Females_train_data];
labels_train = [-1*ones(size(Males_train_data,1),1); 1*ones(size(Females_train_data,1),1)];
options = [];
[eigvector, eigvalue] = LDA(labels_train,options,input);

%% Test LDA:
disp('Testing LDA...');
train_data{1} = Males_train_data;
train_data{2} = Females_train_data;
test_data = [Males_test_data; Females_test_data];
eigvector_LDA = eigvector;
recognized_labels = LDA_test(train_data, test_data, eigvector_LDA);
recognized_labels(recognized_labels == 1) = -1;
recognized_labels(recognized_labels == 2) = 1;
recognized_labels_males = recognized_labels(1:length(recognized_labels)/2);
recognized_labels_females = recognized_labels(length(recognized_labels)/2 + 1:end);
recognized_labels = [recognized_labels_males, recognized_labels_females];   %--> column 1: test males, column 2: test females | -1 means recognizing male, 1 means recognizing female
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


