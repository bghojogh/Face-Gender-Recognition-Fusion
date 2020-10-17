function recognized_labels = LDA_test(train_data, test_data, eigvector_LDA)

    %% guide:
    %%%%% train_data --> a cell matrix: every cell is training data for a class, in every cell --> rows: every train sample, columns: dimensions
    %%%%% test data --> rows: every test sample, columns: dimensions
    %%%%% eigvector_LDA --> dimensions_of_data * (C-1)
    %%%%% recognized_labels --> rows: recognized labels of every test sample --> label #n means class n (according to order in train_data)

    u_norm_LDA = eigvector_LDA';
    
    %% find projected mean of classes:
    for i = 1:length(train_data)
        mean_of_train_data{i} = mean(train_data{i}, 1);
        projected_mean_train{i} = u_norm_LDA * mean_of_train_data{i}';
    end
    
    %% project test data onto LDA subspace:
    for i = 1:size(test_data,1)
        projected_test(i,:) = u_norm_LDA * test_data(i,:)';
    end
    
    %% recognize test data:
    for i = 1:size(test_data,1)
        for k = 1:length(train_data)
            distance(k) = Euclidean_distance(projected_test(i,:), projected_mean_train{k});
        end
        [~,index_estimated_class] = min(distance);
        recognized_labels(i,1) = index_estimated_class;
    end

end