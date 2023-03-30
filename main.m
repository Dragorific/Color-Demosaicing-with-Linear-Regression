% MUHAMMAD UMAR KHAN | 400167784 | KHANM214

% ------------------------ SIMULATED MOSAICS FROM IMAGE--------------------
% -------------------------------------------------------------------------

% Read the image
img = imread("dwip.jpeg");

% Convert the image to linear representation
img_linear = double(img) / 255;

% Get the size of the image
[height, width, ~] = size(img_linear);

% Initialize mosaic patches
RGGB = zeros(height, width);
GRBG = zeros(height, width);
GBRG = zeros(height, width);
BGGR = zeros(height, width);

% Create the mosaic patches
for y = 1:height
    for x = 1:width
        R = img_linear(y, x, 1);
        G = img_linear(y, x, 2);
        B = img_linear(y, x, 3);
        
        % RGGB
        if mod(y, 2) == 1 && mod(x, 2) == 1
            RGGB(y, x) = R;
        elseif mod(y, 2) == 0 && mod(x, 2) == 0
            RGGB(y, x) = B;
        else
            RGGB(y, x) = G;
        end
        
        % GRBG
        if mod(y, 2) == 1 && mod(x, 2) == 1
            GRBG(y, x) = G;
        elseif mod(y, 2) == 0 && mod(x, 2) == 0
            GRBG(y, x) = G;
        elseif mod(y, 2) == 1 && mod(x, 2) == 0
            GRBG(y, x) = R;
        else
            GRBG(y, x) = B;
        end
        
        % GBRG
        if mod(y, 2) == 1 && mod(x, 2) == 1
            GBRG(y, x) = G;
        elseif mod(y, 2) == 0 && mod(x, 2) == 0
            GBRG(y, x) = G;
        elseif mod(y, 2) == 1 && mod(x, 2) == 0
            GBRG(y, x) = B;
        else
            GBRG(y, x) = R;
        end
        
        % BGGR
        if mod(y, 2) == 1 && mod(x, 2) == 1
            BGGR(y, x) = B;
        elseif mod(y, 2) == 0 && mod(x, 2) == 0
            BGGR(y, x) = R;
        else
            BGGR(y, x) = G;
        end
    end
end

% Display the mosaic patches
figure;
subplot(2, 2, 1);
imshow(RGGB);
title('RGGB');
subplot(2, 2, 2);
imshow(GRBG);
title('GRBG');
subplot(2, 2, 3);
imshow(GBRG);
title('GBRG');
subplot(2, 2, 4);
imshow(BGGR);
title('BGGR');

% Separate color channels for each mosaic
mosaics = {RGGB, GRBG, GBRG, BGGR};
mosaic_channels = cell(4, 3);

for i = 1:4
    mosaic = mosaics{i};
    
    % Green channel
    green_channel = mosaic(2:2:end, 2:2:end);
    mosaic_channels{i, 1} = green_channel;
    
    % Red/Blue channels
    rb_channel1 = mosaic(1:2:end, 1:2:end);
    rb_channel2 = mosaic(2:2:end, 1:2:end);
    mosaic_channels{i, 2} = rb_channel1;
    mosaic_channels{i, 3} = rb_channel2;
end

% ----------------------- OPTIMAL COEFFICIENT MATRICES --------------------
% -------------------------------------------------------------------------

% Calculate the optimal coefficient matrices for each mosaic
optimal_coefficients = cell(4, 2);

for i = 1:4
    mosaic = mosaics{i};
    channels = mosaic_channels(i, :);
    
    % Calculate the green channel coefficient matrix
    green_coeff = calculate_coefficient_matrix(mosaic, channels{1}, 'green');
    optimal_coefficients{i, 1} = green_coeff;
    
    % Calculate the red/blue channel coefficient matrix
    rb_coeff = calculate_coefficient_matrix(mosaic, channels{2}, 'red_blue');
    optimal_coefficients{i, 2} = rb_coeff;
end

% Display the optimal coefficient matrices
mosaic_names = {'RGGB', 'GRBG', 'GBRG', 'BGGR'};
for i = 1:4
    fprintf('%s Green Channel Coefficient Matrix:\n', mosaic_names{i});
    disp(optimal_coefficients{i, 1});
    fprintf('%s Red/Blue Channel Coefficient Matrix:\n', mosaic_names{i});
    disp(optimal_coefficients{i, 2});
end

% Apply the coefficient matrices to the mosaic images
demosaiced_images = cell(1, 4);
mosaic_patterns = {'RGGB', 'GRBG', 'GBRG', 'BGGR'};

for i = 1:4
    mosaic = mosaics{i};
    green_coeff = optimal_coefficients{i, 1};
    rb_coeff = optimal_coefficients{i, 2};
    pattern = mosaic_patterns{i};
    
    demosaiced_image = apply_coefficient_matrices(mosaic, green_coeff, rb_coeff, pattern);
    demosaiced_images{i} = demosaiced_image;
end


% -------------------- RECONSTRUCTING IMAGE FROM MOSAIC -------------------
% -------------------------------------------------------------------------

reconstructed_image = zeros(height, width, 3);

% Fill in the missing color channels in the mosaics
for i = 1:4
    mosaic = mosaics{i};
    demosaiced_image = demosaiced_images{i};
    pattern = mosaic_patterns{i};
    
    for y = 1:2:height - 1
        for x = 1:2:width - 1
            if strcmp(pattern, 'RGGB')
                reconstructed_image(y, x, 1) = mosaic(y, x);
                reconstructed_image(y, x, 2) = demosaiced_image(y, x, 2);
            elseif strcmp(pattern, 'GRBG')
                reconstructed_image(y, x, 2) = mosaic(y, x);
                reconstructed_image(y, x + 1, 1) = mosaic(y, x + 1);
            elseif strcmp(pattern, 'GBRG')
                reconstructed_image(y, x, 2) = mosaic(y, x);
                reconstructed_image(y, x + 1, 3) = mosaic(y, x + 1);
            elseif strcmp(pattern, 'BGGR')
                reconstructed_image(y, x, 3) = mosaic(y, x);
                reconstructed_image(y, x, 2) = demosaiced_image(y, x, 2);
            end
        end
    end
end

% Interpolate the missing values in reconstructed_image
for ch = 1:3
    tmp_img = reconstructed_image(:,:,ch);
    tmp_img = imresize(tmp_img, [height*2, width*2], 'bilinear');
    reconstructed_image(:,:,ch) = imresize(tmp_img, [height, width], 'bilinear');
end

% Normalize the reconstructed image to the range [0, 1]
reconstructed_image = reconstructed_image - min(reconstructed_image(:));
reconstructed_image = reconstructed_image / max(reconstructed_image(:));

% Convert the reconstructed image back to the [0, 255] range
reconstructed_image = uint8(reconstructed_image * 255);

% Apply the Guided Filter (Optional Filtering to Improve Accuracy)
radius = 8;             % Radius of the window used for filtering, you can adjust this value
epsilon = 0.1^2;       % Regularization parameter, you can adjust this value
filtered_image = imguidedfilter(reconstructed_image, 'NeighborhoodSize', [radius radius], 'DegreeOfSmoothing', epsilon);

% Display the filtered image
figure;
imshow(filtered_image);
title('Filtered Image');

% % Display the reconstructed image
% figure;
% imshow(reconstructed_image);
% title('Reconstructed Image');

demosaiced_image_mat = demosaic(uint8(mosaics{1} * 255), 'RGGB');
% Display the demosaiced image
figure;
imshow(demosaiced_image_mat);
title('Demosaiced Image w/ MATLAB');


% ---------------------- MEASURING RMSE -----------------------------------
% -------------------------------------------------------------------------


% Ensure both images are in the same representation (e.g., linear)
reconstructed_linear = double(reconstructed_image) / 255;

% Compute the squared differences between the corresponding pixel values
squared_diffs = (img_linear - reconstructed_linear).^2;

% Calculate the mean of the squared differences
mean_squared_diffs = mean(squared_diffs(:));

% Take the square root of the mean to obtain the RMSE value
rmse = sqrt(mean_squared_diffs);

% Display the RMSE value
fprintf('RMSE: %f\n', rmse);

