function x_ridge = ridge_regression(A, b, alpha)
    % A: feature matrix (N x P)
    % b: target vector (N x 1)
    % alpha: regularization parameter

    % Calculate the ridge regression solution
    ATA = A' * A;
    ATb = A' * b;
    I = eye(size(ATA));
    x_ridge = (ATA + alpha * I) \ ATb;
end