% Function to apply the coefficient matrices to approximate the missing colors
function demosaiced_image = apply_coefficient_matrices(mosaic, green_coeff, rb_coeff, pattern)
    [height, width] = size(mosaic);
    demosaiced_image = zeros(height, width, 3);
    
    for y = 1:2:height - 1
        for x = 1:2:width - 1
            patch = mosaic(y:y + 1, x:x + 1);
            green_approximation = sum(sum(patch .* green_coeff));
            rb_approximation = sum(sum(patch .* rb_coeff));
            
            if strcmp(pattern, 'RGGB')
                demosaiced_image(y, x, 2) = green_approximation;
                demosaiced_image(y, x, 1) = rb_approximation;
            elseif strcmp(pattern, 'GRBG')
                demosaiced_image(y, x, 2) = green_approximation;
                demosaiced_image(y, x + 1, 1) = rb_approximation;
            elseif strcmp(pattern, 'GBRG')
                demosaiced_image(y, x, 2) = green_approximation;
                demosaiced_image(y, x + 1, 3) = rb_approximation;
            elseif strcmp(pattern, 'BGGR')
                demosaiced_image(y, x, 2) = green_approximation;
                demosaiced_image(y, x, 3) = rb_approximation;
            end
        end
    end
end