%% pre-processing:
clc
clear 
clear all
close all

%% load results:
cd('./votes/vote1');
load recognized_labels_males.mat 
load recognized_labels_females.mat 
load rate.mat
cd('..'); cd('..');
vote1_males = recognized_labels_males;
vote1_females = recognized_labels_females;
vote1_rate = rate;

cd('./votes/vote2');
load recognized_labels_males.mat 
load recognized_labels_females.mat
load rate.mat
cd('..'); cd('..');
vote2_males = recognized_labels_males;
vote2_females = recognized_labels_females;
vote2_rate = rate;

cd('./votes/vote3');
load recognized_labels_males.mat 
load recognized_labels_females.mat 
load rate.mat
cd('..'); cd('..');
vote3_males = recognized_labels_males;
vote3_females = recognized_labels_females;
vote3_rate = rate;

cd('./votes/vote4');
load recognized_labels_males.mat 
load recognized_labels_females.mat 
load rate.mat
cd('..'); cd('..');
vote4_males = recognized_labels_males;
vote4_females = recognized_labels_females;
vote4_rate = rate;

%% Vote (fusion):
votes_males = [vote1_males, vote2_males, vote3_males, vote4_males];
votes_females = [vote1_females, vote2_females, vote3_females, vote4_females];
number_of_test_persons = size(votes_males,1);
for i = 1:number_of_test_persons
    vote_males(i,1) = (vote1_rate * votes_males(i,1)) + (vote2_rate * votes_males(i,2)) + (vote3_rate * votes_males(i,3)) + (vote4_rate * votes_males(i,4));
    vote_females(i,1) = (vote1_rate * votes_females(i,1)) + (vote2_rate * votes_females(i,2)) + (vote3_rate * votes_females(i,3)) + (vote4_rate * votes_females(i,4));
end
vote_males(vote_males < 0) = -1;
vote_males(vote_males > 0) = 1;
vote_females(vote_females < 0) = -1;
vote_females(vote_females > 0) = 1;
rate_male_tests = sum(vote_males(:,1) == -1) / length(vote_males);
rate_female_tests = sum(vote_females(:,1) == 1) / length(vote_females);
rate_total = mean([rate_male_tests, rate_female_tests]);

%% report results:
disp('Recognition rate:');
disp(rate_total);
disp('Recognition rate of males:');
disp(rate_male_tests);
disp('Recognition rate of females:');
disp(rate_female_tests);

%% save results:
cd('saved_results');
save vote_males.mat vote_males
save vote_females.mat vote_females
save rate_total.mat rate_total
save rate_male_tests.mat rate_male_tests
save rate_female_tests.mat rate_female_tests
cd('..');


