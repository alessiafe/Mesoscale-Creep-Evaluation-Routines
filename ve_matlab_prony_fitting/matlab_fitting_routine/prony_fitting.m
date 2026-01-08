function fit_data = prony_fitting(fit_data, N, gamma_0, tau_0, err)
    % Fit creep strain data to Prony series.
    % Inputs:
    % - fit_data = struct of data (time, creep strain, creep stress,...)
    % Optional input:
    % - N = num. of KV elements
    % - gamma_0 = initial value of gamma_i (Prony coeff.)
    % - tau_0 = relaxation time array (pre-defined)
    % - err = type of optimization object -> Sum of Squares Error (SSE)
    %   (absolute or relative)

    %% Prony series default settings
    N_def = 4; % num. of KV elements
    gamma_0_def = [1, 1 ,1, 1]; % gamma_i initial values
    tau_0_def = [0.1, 1, 10, 100]; % tau_i pre-defined values
    err_def = 'rel'; % type of optimization obj -> relative SSE
    switch nargin
        case 1
            N = N_def;
            gamma_0 = gamma_0_def;
            tau_0 = tau_0_def;
            err = err_def;
        case 2
            gamma_0 = gamma_0_def;
            tau_0 = tau_0_def;
            err = err_def;
        case 3
            tau_0 = tau_0_def;
            err = err_def;
        case 4
            err = err_def;
        case 5
        otherwise
            error('Only 5 inputs are accepted.')
    end

    %% Prony fitting
    for k=1:length(fit_data.sample_name)
        time = fit_data.time{k}'; % time [h] (from elastic loading on)
        strain = fit_data.creep_strain{k}; % creep strain
        % Filter data
        % Filter out negative strains
        pos_idx = strain >= 0; % positions of non-negative strains
        ydata = strain(pos_idx); % extract only non-negative strains
        tdata = time(pos_idx); % extract time of non-negative strains
        % Fit an exponential model
        ydata = ydata(2:end); % strains
        tdata = tdata(2:end); % time
        fitObj = fit(tdata(:), ydata(:), 'exp1'); % fit exponential model
        detrended_strains = ydata - feval(fitObj, tdata); % detrended data
        % Smooth the data using a moving average filter
        window_size = 5; % window size
        smoothed_strains = movmean(detrended_strains, window_size); % moving average filter
        % Identify peaks using a threshold method
        threshold = 1 * std(smoothed_strains); % threshold
        peaks = abs(smoothed_strains) > threshold; % peaks
        % Cut peaks out
        strain(1.+find(peaks~=0)) = [];
        time(1.+find(peaks~=0)) = [];

        
        creep_stress = fit_data.creep_stress{k}; % creep stress [MPa]
        sol = opt_strain_prony(strain/creep_stress, time, N, gamma_0, tau_0, err); % fit prony series
        fit_data.gamma_i{k} = sol.gamma_i; % store gamma_i
        fit_data.tau_i{k} = tau_0'; % store tau_i
    end
end