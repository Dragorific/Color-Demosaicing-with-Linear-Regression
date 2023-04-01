function img_reconstructed = image_reconstruction(img_mosaic, patch_size, alpha)
    % img_mosaic: input mosaic image (H x W)
    % patch_size: size of the overlapping patches (odd integer)
    % alpha: regularization parameter

    % Get image dimensions
    [H, W] = size(img_mosaic);

    % Initialize reconstructed image (H x W x 3)
    img_reconstructed = zeros(H, W, 3);

    % Iterate through the image with overlapping patches
    half_patch = (patch_size - 1) / 2;
    for row = 1:patch_size:H
        for col = 1:patch_size:W
            % Extract patch
            patch = img_mosaic(max(row - half_patch, 1):min(row + half_patch, H), ...
                               max(col - half_patch, 1):min(col + half_patch, W));

            % Get patch dimensions
            [h_patch, w_patch] = size(patch);

            % Create A matrix and b vector
            A = [];
            b = [];
            for i = 1:h_patch
                for j = 1:w_patch
                    if mod(i, 2) == 1 && mod(j, 2) == 1
                        % Red channel
                        A(end+1, :) = [patch(i, j), 0, 0];
                        b(end+1, 1) = img_mosaic(row + i - 1, col + j - 1);
                    elseif mod(i, 2) == 0 && mod(j, 2) == 0
                        % Blue channel
                        A(end+1, :) = [0, 0, patch(i, j)];
                        b(end+1, 1) = img_mosaic(row + i - 1, col + j - 1);
                    else
                        % Green channel
                        A(end+1, :) = [0, patch(i, j), 0];
                        b(end+1, 1) = patch(i, j);
                    end
                end
            end

            % Solve Tikhonov regularization for the current patch
            x_ridge = ridge_regression(A, b, alpha);

            % Reconstruct missing values in the current patch
            idx = 1;
            for i = 1:h_patch
                for j = 1:w_patch
                    if mod(i, 2) == 1 && mod(j, 2) == 1
                        % Red channel
                        img_reconstructed(row + i - 1, col + j - 1, 1) = x_ridge(1) * patch(i, j);
                    elseif mod(i, 2) == 0 && mod(j, 2) == 0
                        % Blue channel
                        img_reconstructed(row + i - 1, col + j - 1, 3) = x_ridge(3) * patch(i, j);
                    else
                        % Green channel (already known)
                        img_reconstructed(row + i - 1, col + j - 1, 2) = patch(i, j);
                    end
                end
            end
        end
    end
end
