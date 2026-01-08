function KV = Ftest_prony(data, gamma_0, tau_0, err)
    % Use the F-test to find the optimal number of KV elements:
    % compare models with N and N+1 terms to determine if the additional
    % term significantly improves the fit.
    % Inputs:
    % - data = struct of data (time, creep strain, creep stress,...)
    % Optional inputs:
    % - gamma_0 = initial value of gamma_i (Prony coefficients)
    % - tau_0 = relaxation time array
    % - err = type of Sum of Squares Error (SSE) for fitting process 
    %   (absolute or relative)
    % Add references and legend:
    % - F2 = 
    % - F =
    % - KV = num. of KV elements

    %% Prony series default settings
    gamma_0_def = 1; % gamma_i initial value
    tau_0_def = 0.1; % tau_i 1st value
    err_def = 'rel'; % type of SSE -> relative
    switch nargin
        case 1
            gamma_0 = gamma_0_def;
            tau_0 = tau_0_def;
            err = err_def;
        case 2
            tau_0 = tau_0_def;
            err = err_def;
        case 3
            err = err_def;
        case 4
        otherwise
            error('Only 4 inputs are accepted.')
    end

    %% F-test settings
    F2 = 2.9995; % F2 initial value
    F = F2 + 1; % initial F to enter the while loop
    KV = 2; % initial number of KV elements
    %% Run F-test
    creep_stress = data.creep_stress; % creep stress [MPa]
    while F > F2  
        % Set input data
        tdata = data.time'; % time [h] (from elastic loading on)
        ydata = data.creep_strain/creep_stress; % creep compliance
        % Find Prony fitting
        SSE_N = [0 0]; % Initialize SSE array
        for k = 1:2 % repeat for N and N+1 elements   
            gamma_i = gamma_0 * ones(1,KV); % gamma_i initial values
            tau_i = 10.^(log10(tau_0):log10(tau_0)+KV-1); % tau_i values
            sol = opt_strain_prony(ydata, tdata, KV, gamma_i, tau_i, err); % fit prony series
            SSE_N(k) = Ftest_SSE(ydata, tdata, sol); % calculate SSE
            KV = KV + 1; % increase number of elements for comparison
        end
        n = 1; % number of additional parameters = (KV+1)-KV
        m = length(ydata); % number of data points
        F = (SSE_N(1)-SSE_N(2))/n/(SSE_N(2)/(m-(KV))); % calculate F
        F2 = finv(1 - 0.05, n, m - (KV)); % calculate F2
        KV = KV - 1; % decrease number of elements to re-start comaprison process
    end
end

