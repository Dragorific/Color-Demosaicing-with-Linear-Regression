% Function to calculate the optimal coefficient matrix
function C = calculate_coefficient_matrix(mosaic, target_channel, channel_type)
    [target_height, target_width] = size(target_channel);
    A = zeros((target_height - 1) * (target_width - 1), 4);
    b = zeros((target_height - 1) * (target_width - 1), 1);
    count = 1;

    for y = 1:target_height - 1
        for x = 1:target_width - 1
            % 2x2 patch from the mosaic
            if strcmp(channel_type, 'green')
                patch = [mosaic(2*y - 1, 2*x), mosaic(2*y, 2*x - 1);
                         mosaic(2*y - 1, 2*x - 1), mosaic(2*y, 2*x)];
            else
                patch = [mosaic(2*y - 1, 2*x - 1), mosaic(2*y, 2*x);
                         mosaic(2*y - 1, 2*x), mosaic(2*y, 2*x - 1)];
            end

            % Manually create the row vector from the 2x2 patch
            A(count, 1) = patch(1, 1);
            A(count, 2) = patch(1, 2);
            A(count, 3) = patch(2, 1);
            A(count, 4) = patch(2, 2);
            
            b(count) = target_channel(y, x);
            count = count + 1;
        end
    end

    % Solve the non-negative least square problem
    C = lsqnonneg(A, b);
    C = reshape(C, 2, 2);
end