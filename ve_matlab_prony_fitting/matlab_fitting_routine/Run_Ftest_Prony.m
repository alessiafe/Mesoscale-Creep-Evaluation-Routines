
close all
clc
clear
warning ('off','all');

%% Default paths
resultsPath = '/home/aferrara/Desktop/creep-evaluation-routine/ve_matlab_prony_fitting/VE_Creep_Results';
%% Set experimental situations
sample_type = {'LT-EW', 'LT-LW', 'LR', 'RT', 'RL','TR','TL-EW'}; % possible value: [LT-EW, LT-LW, LR, RT, RL, TR, TL-EW, TL-LW]
ref_RH = [30, 65, 90]; % possible value: [30, 65, 90]
ref_LD = [0.3, 0.5]; % possible value: [0.3, 0.5]

%% Run F-test
gamma_0 = 1;
tau_0 = 0.1;
for s=1:length(sample_type)
    for r=1:length(ref_RH)
        for l=1:length(ref_LD)
            % Load creep data
            fit_data = load_creep_data(resultsPath, sample_type{s}, ...
                ref_RH(r), ref_LD(l)); % load data
            % Run F-test for each situation
            fields = fieldnames(fit_data);
            for k=1:length(fit_data.sample_name)
                for i=1:length(fields)
                    fieldName = fields{i};
                    if iscell(fit_data.(fieldName))
                        test_data.(fieldName) = fit_data.(fieldName){k};
                        if strcmp(fieldName,'creep_strain_axial')
                            test_data.(fieldName)(isnan(test_data.(fieldName))) = 0;
                        end
                    elseif isnumeric(fit_data.(fieldName)) && length(fit_data.(fieldName)) > 1
                        test_data.(fieldName) = fit_data.(fieldName)(k);
                    else
                        test_data.(fieldName) = fit_data.(fieldName);
                    end
                end
                KV(k) = Ftest_prony(test_data, gamma_0, tau_0,'rel');
            end
            % Store data
            current_results.sample = sample_type{s};
            current_results.RH = ref_RH(r);
            current_results.loading_deg = ref_LD(l);
            current_results.KV = KV;
            if exist('Ftest_results', 'var') == 1
                Ftest_results = [Ftest_results, current_results];
            else
                Ftest_results = current_results;
            end
        end
    end
end

%% Show results
KV = {Ftest_results.KV};
allKV = [KV{:}]; % concatenate arrays into a single array
% Find unique values and their counts
[uniqueValues, ~, idx] = unique(allKV);
counts = histcounts(idx, length(uniqueValues));
% Display the result
disp('KV values and their counts:');
for i = 1:length(uniqueValues)
    fprintf('Value: %d, Count: %d\n', uniqueValues(i), counts(i));
end
disp('Done.');

