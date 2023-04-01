% Read the raw image (grayscale)
img = imread('dwip.jpeg');

% Convert the image to linear representation
img_linear = double(img) / 255;

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

% Get the image dimensions
[rows, cols] = size(RGGB);

% Initialize the color channels
red_channel = zeros(rows, cols);
green_channel = zeros(rows, cols);
blue_channel = zeros(rows, cols);

% Iterate through the raw image data to extract the color channels
for row = 1:rows
    for col = 1:cols
        if mod(row, 2) == 1 && mod(col, 2) == 1
            red_channel(row, col) = RGGB(row, col);
        elseif mod(row, 2) == 0 && mod(col, 2) == 0
            blue_channel(row, col) = RGGB(row, col);
        else
            green_channel(row, col) = RGGB(row, col);
        end
    end
end

% Perform simple bilinear interpolation
red_channel = imfilter(red_channel, [1 2 1; 2 4 2; 1 2 1]/4, 'same', 'replicate', 'conv');
green_channel = imfilter(green_channel, [0 1 0; 1 4 1; 0 1 0]/4, 'same', 'replicate', 'conv');
blue_channel = imfilter(blue_channel, [1 2 1; 2 4 2; 1 2 1]/4, 'same', 'replicate', 'conv');

% Merge the color channels
demosaiced_image = cat(3, red_channel, green_channel, blue_channel);

% Convert to 8-bit unsigned integer and display the result
demosaiced_image = uint8(demosaiced_image * 255);
imshow(demosaiced_image);
