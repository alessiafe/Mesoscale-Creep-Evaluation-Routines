
close all
clc
clear
warning ('off','all');

%% Default paths
resultsPath = '/home/aferrara/Desktop/creep-evaluation-routine/ve_matlab_prony_fitting/VE_Creep_Results';

%% Load elastic data
elastic_file = 'elastic_compliances.csv';
elastic_path = fullfile(resultsPath, elastic_file);
elastic = readtable(elastic_path);

%% Set experimental situations
sample_type = {'LT-LW','LT-EW','LR','RT','RL','TR'};
ref_RH = [30, 65, 90]; % possible values: [30, 65, 90]
ref_LD = [0.3, 0.5]; % possible values: [0.3, 0.5]
%% Set Prony series parameters
N = 4; % num. of KV elements
tau_exp = -1;
tau_0 = 10.^(tau_exp:tau_exp+N-1); % tau_i pre-defined values
err = 'rel'; % type of SSE (optimization object)
% initialize array
fit_data = cell(length(sample_type), length(ref_RH), length(ref_LD));

%% Fit creep data
for r=1:length(ref_RH)
    temp_gamma_0 = 1 * ones(1,N); % gamma_i initial values  
    for s=1:length(sample_type)
        % Update initial gamma_0
        rows = (elastic.RH==ref_RH(r)) & (strcmp(elastic.sample_type, sample_type{s}));
        C0 = elastic.C0(rows);
        gamma_0 = temp_gamma_0/C0;
        temp_fit_data = struct();
        for l=1:length(ref_LD)
            %% Fit and store data for each sample
            % Load creep data
            fit_data{s,r,l} = load_creep_data(resultsPath, sample_type{s}, ref_RH(r), ref_LD(l));
            % Fit creep data
            fit_data{s,r,l} = prony_fitting(fit_data{s,r,l}, N, gamma_0, tau_0, err);
            % Store sample data
            if exist('samples_results', 'var') == 1
                samples_results = [samples_results, save_samples_prony(fit_data{s,r,l})];
            else
                samples_results = save_samples_prony(fit_data{s,r,l});
            end

            %% Merge compliances for LD
            fields = fieldnames(fit_data{s,r,l});
            % Loop through each field and concatenate arrays
            for i = 1:length(fields)
                field = fields{i};
                if l == 1
                    temp_fit_data.(field) = fit_data{s,r,l}.(field);
                else
                    if ischar(fit_data{s,r,l}.(field)) || isstring(fit_data{s,r,l}.(field))
                        temp_fit_data.(field) = fit_data{s,r,l}.(field);
                    else
                        temp_fit_data.(field) = [temp_fit_data.(field), fit_data{s,r,l}.(field)];
                    end
                end
            end
        end

        for l=1:length(ref_LD) 
            %% Calculate statistics
            % Calculate mean and 95% conf.int of fitted data, and then fit gamma_i
            fit_data{s,r,l}.prony_param = statistics_prony(temp_fit_data, N, gamma_0, tau_0);
            %% Store data
            % Store general data
            if exist('prony_results', 'var') == 1
                prony_results = [prony_results, save_general_prony(fit_data{s,r,l})];
            else
                prony_results = save_general_prony(fit_data{s,r,l});
            end
        end
        % Update temp_gamma_0
        temp_gamma_0 = fit_data{s,r,l}.prony_param(:,1)*C0;

        %% Plot data
        %plot_fitted_data(temp_fit_data);
        %plot_statistics(temp_fit_data, fit_data{s,r,l}.prony_param);
        
    end
end

%% Save data
save(fullfile(resultsPath,'samples_prony_compliance.mat'), 'samples_results');
save(fullfile(resultsPath,'general_prony_compliance.mat'), 'prony_results');
disp('Done!');




