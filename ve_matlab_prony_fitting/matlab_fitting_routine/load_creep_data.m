function fit_data = load_creep_data(resultsPath, sampleType, refRH, refLoadDeg)

    savePath = fullfile(resultsPath,strcat(sampleType,'_samples')); % results folder path

    %% Check results folder
    if ~exist(savePath,'dir') % check if the folder exists
        error("The folder %s does not exist.\n",char(savePath));
    else
        list = ls(savePath);
        if isempty(list) % check if the folder is empty
            error("The folder %s exists but it's empty.\n",char(savePath));
        else
            fprintf("Working on %s.\n",char(savePath));
        end
    end

    %% Load data table
    export_file_table = fullfile(savePath,strcat(sampleType,'_samples_table.mat')); % table path
    export_table = load(export_file_table); % load table
    export_table = export_table.export_table; % get table data

    %% Get sample list corresponding to ref. RH and Load. Deg.
    k = ([export_table.RH]==refRH & [export_table.nominal_loading_degree]==refLoadDeg); % position of ref. RH value
    samples = {export_table(k).sample_name}'; % get sample names corresponding to ref. RH

    %% Load data structures
    export_results = cell(length(samples), 1); % initilaize cell array
    for k=1:length(samples)
        export_file_results = fullfile(savePath,strcat(char(samples(k)),'_results.mat')); % data structure path
        export_results{k} = load(export_file_results); % load data structure
    end

    %% Store input data for fitting
    for k=1:length(samples)
        eval_idx = export_results{k}.strain_eval_idx;
        fit_data.exp_code{k} = export_results{k}.exp_code;
        fit_data.sample_name{k} = export_results{k}.sample_name;
        fit_data.time{k} = export_results{k}.dt_h(eval_idx(3):end)-...
            export_results{k}.dt_h(eval_idx(3));
        fit_data.el_strain(k) = export_results{k}.total_axial_strain(eval_idx(3));
        fit_data.creep_strain{k} = export_results{k}.total_axial_strain(eval_idx(3):end)-fit_data.el_strain(k);
        
        fit_data.creep_stress{k} = export_results{k}.creep_stress_MPa;
    end
    fit_data.sample_type = sampleType;
    fit_data.RH = refRH;
    fit_data.loading_deg = refLoadDeg;

end