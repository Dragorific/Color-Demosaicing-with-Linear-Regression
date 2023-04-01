% Read the raw image (grayscale)
raw_image = imread('dwip.jpeg');

% Convert the image to linear representation
img_linear = double(raw_image) / 255;

% Get the size of the image
[height, width, ~] = size(img_linear);

% Initialize mosaic patches
RGGB = zeros(height, width);

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
    end
end

% Set the patch size and regularization parameter
patch_size = 5;
alpha = 0.01;

% Apply the image reconstruction function
img_reconstructed = image_reconstruction(RGGB, patch_size, alpha);

% Convert to 8-bit unsigned integer and display the result
img_reconstructed = uint8(img_reconstructed*255);
imshow(img_reconstructed);