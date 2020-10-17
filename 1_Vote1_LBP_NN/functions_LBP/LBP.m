function feature_vector = LBP(Image, LBP_type)

Image = Image(:,:,1);
Image = double(Image);
%%%% iteration on pixels of image:
counter_pixel = 1;
for i=2:(size(Image,1)-1)
    for j=2:(size(Image,2)-1)
        %%%% iteration on surronding pixels of the pixel:
        feature_vector_of_a_pixel = [];
        for k=i-1:i+1
            for z=j-1:j+1
                if ~(i == k && j == z)
                    if Image(k,z) < Image(i,j)
                        feature_vector_of_a_pixel(1,end+1) = 0;
                    else
                        feature_vector_of_a_pixel(1,end+1) = 1;
                    end
                end
            end
        end
        %%%% check for the smallest feature_vector_of_a_pixel:
        dimension_of_feature_vector = length(feature_vector_of_a_pixel);
        for rotation_index = 1:dimension_of_feature_vector
            %%%% finding amount of feature_vector_of_a_pixel:
            amount_of_feature_vector = 0;
            for bit_index = 1:dimension_of_feature_vector
                amount_of_feature_vector = amount_of_feature_vector + feature_vector_of_a_pixel(bit_index)*(2^(dimension_of_feature_vector-bit_index));
            end
            %%%% finding smallest amount of feature_vector_of_a_pixel:
            if rotation_index == 1
                smallest_feature_vector_of_a_pixel = feature_vector_of_a_pixel;
                smallest_amount_of_feature_vector = amount_of_feature_vector;
            elseif amount_of_feature_vector < smallest_amount_of_feature_vector
                smallest_feature_vector_of_a_pixel = feature_vector_of_a_pixel;
                smallest_amount_of_feature_vector = amount_of_feature_vector;
            end
            %%%% rotate one bit right-wise:
            temp = feature_vector_of_a_pixel(1:end-1);
            temp2 = feature_vector_of_a_pixel(end);
            feature_vector_of_a_pixel = [temp2, temp];
        end
        %%%% put the feature of this pixel in feature vector:
        if strcmp(LBP_type, 'simple_LBP')
            feature_vector(counter_pixel) = smallest_amount_of_feature_vector;
        elseif strcmp(LBP_type, 'uniform_LBP')
            number_of_changes_of_pattern = 0;
            for bit_index = 1:dimension_of_feature_vector-1
                if smallest_feature_vector_of_a_pixel(bit_index) ~= smallest_feature_vector_of_a_pixel(bit_index+1)
                    number_of_changes_of_pattern = number_of_changes_of_pattern + 1;
                end
            end
            if number_of_changes_of_pattern <= 2  %%%---> it is uniform
                feature_vector(counter_pixel) = sum(smallest_feature_vector_of_a_pixel);
            else
                feature_vector(counter_pixel) = dimension_of_feature_vector + 1;
            end
        end
        counter_pixel = counter_pixel + 1;
    end
end

end