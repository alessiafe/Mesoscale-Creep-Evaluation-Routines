function prony_param = statistics_prony(fit_data, N, gamma_0, tau_0)

    %% Prony series default settings
    N_def = 4;
    gamma_0_def = [1, 1 ,1 ,1];
    tau_0_def =  [0.1, 1, 10, 100];
    switch nargin
        case 1
            N = N_def;
            gamma_0 = gamma_0_def;
            tau_0 = tau_0_def;
        case 2
            gamma_0 = gamma_0_def;
            tau_0 = tau_0_def;
        case 3
            tau_0 = tau_0_def;
        case 4
        otherwise
            error('Only 2 inputs are accepted.')
    end

    %% Calculate fitted data for each sample
    num_pt = 1000;
    %tdata_fit = linspace(0,max(cellfun(@(x) x(end), fit_data.time)),num_pt)';
    tdata_fit = linspace(0,fit_data.tau_i{1}(end),num_pt)';
    responsedata = zeros(length(fit_data.sample_name),num_pt);
    for k=1:length(fit_data.sample_name)
        %creep_stress = fit_data.creep_stress{k};
        fun = @(gamma_i, tau_i) (sum(1./gamma_i) - sum(1./gamma_i' .* exp(-tdata_fit./tau_i'),2));  
        responsedata(k, :) = fun(fit_data.gamma_i{k},fit_data.tau_i{k});
    end

    %% Calculate mean fitted data
    mean_fit = mean(responsedata, 1); % mean creep strain
    %creep_stress = mean([fit_data.creep_stress{:}]); % mean creep stress
    sol = opt_strain_prony(mean_fit', tdata_fit, N, gamma_0, tau_0); % fit prony series
    prony_param(:,1) = sol.gamma_i; % store prony coefficients
    
    %% Calculate 95% confidence interval (ci)
    std_fit = std(responsedata, 1); % standard deviation of creep strain
    n = length(fit_data.sample_name); % number of samples
    stderr_fit = std_fit / sqrt(n); % standard error of creep strain
    z = norminv(0.975); % 95% ci of n-distribution %t = tinv(0.975, n-1); % 95% ci of t-distribution
    ci_fit = mean_fit + z * [-stderr_fit; stderr_fit]; % 95% ci
    % Fit lower bound
    sol = opt_strain_prony(ci_fit(1,:)', tdata_fit, N, gamma_0, tau_0); % fit prony series
    prony_param(:,2) = sol.gamma_i;
    % Fit upper bound
    sol = opt_strain_prony(ci_fit(2,:)', tdata_fit, N, gamma_0, tau_0); % fit prony series
    prony_param(:,3) = sol.gamma_i;
end