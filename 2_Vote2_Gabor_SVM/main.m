%% pre-processing:
clc
clear 
clear all
close all

%% Add paths of functions:
addpath('functions');
addpath('functions_PCA');

%% Setting path of input images:
PathName='.\Datasets\1_FEI_resized\';
dirname = fullfile(PathName,'*.jpg');
imglist = dir(dirname);
imgnum = length(imglist);
[~,order] = sort_nat({imglist.name});
imglist = imglist(order);  % imglist is now sorted

%% creat Gabor filters:
disp('Creating Gabor filters...');
wavelength = [2, 5, 8];
orientation = [0 45 90 135];
gaborbank = gabor(wavelength,orientation);

%% applying Gabor filters on image:
filter_again = 0;
if filter_again == 1
    disp('Applying Gabor filters...');
    for i = 1:imgnum
        FileName = imglist(i).name;
        Image = imread([PathName,FileName]);
        [mag{i}, phase{i}] = imgaborfilt(Image, gaborbank);
    end
    cd('saved_files');
    save mag.mat mag
    save phase.mat phase
    cd('..');
else
    disp('Loading Gabor filtered faces...');
    cd('saved_files');
    load mag.mat mag
    load phase.mat phase
    cd('..');
end

%% saving Gabor filtered images for one of the faces:
PathName2 = '.\Datasets\2_Gabor_magnitude\';
PathName3 = '.\Datasets\3_Gabor_phase\';
face_number_to_save = 1;
for i = 1:size(mag{face_number_to_save},3)
    FileName = imglist(i).name;
    Image = imread([PathName,FileName]);
    [mag{i}, phase{i}] = imgaborfilt(Image, gaborbank);
    %%%% save magnitude of gabor filtered faces:
    Gabor_filtered_image = mag{face_number_to_save}(:,:,i) / max(max( mag{face_number_to_save}(:,:,i) ));
    Gabor_filtered_image = Gabor_filtered_image * 255;
    Gabor_filtered_image = imresize(Gabor_filtered_image, [100, NaN]);
    imwrite(uint8(Gabor_filtered_image),[PathName2 'mag' int2str(i) '.jpg']);
    %%%% save phase of gabor filtered faces:
    Gabor_filtered_image = phase{face_number_to_save}(:,:,i) / max(max( phase{face_number_to_save}(:,:,i) ));
    Gabor_filtered_image = Gabor_filtered_image * 255;
    Gabor_filtered_image = imresize(Gabor_filtered_image, [100, NaN]);
    imwrite(uint8(Gabor_filtered_image),[PathName3 'mag' int2str(i) '.jpg']);
end

%% Preparing data:
disp('Preparing data for PCA...');
Males_train_data = [];
Females_train_data = [];
Males_test_data = [];
Females_test_data = [];
for i = 1:imgnum
    number_of_filter_banks = length(wavelength) * length(orientation);
    feature_vector = [];
    for j = 1:number_of_filter_banks
        feature_vector = [feature_vector, reshape(mag{i}(:,:,j), 1, [])];
    end
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

%% Train SVM:
disp('Training SVM...');
Y = [-1*ones(size(Males_train_data,1),1); 1*ones(size(Females_train_data,1),1)];
SVMModel = fitcsvm(input_train,Y,'KernelFunction','rbf','KernelScale','auto');

%% PCA on test:
disp('Applying PCA on test...');
input_test = [Males_test_data; Females_test_data];
egnPow = 0.9999;
Males_test_data = Males_test_data * egnVct;
Females_test_data = Females_test_data * egnVct;

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

