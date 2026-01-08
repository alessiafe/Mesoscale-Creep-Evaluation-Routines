clc
clear
close all
warning ('off','all');

%% Default paths
mainPath = '/home/aferrara/Desktop/creep-evaluation-routine/ve_matlab_prony_fitting';
resultsPath = fullfile(mainPath,'VE_Creep_Results');

%% Define new column names for Excel
listNames = {'Experiment', 'Sample', 'Sample Type', 'Thickness [mm]', 'Width [mm]', ...
    'Area [mm^2]', 'Duration [h]', 'Nominal Load [N]', 'Nominal Stress [MPa]', ...
    'Creep Load [N]', 'Creep Stress [MPa]', 'Failure Load [N]', 'Failure Stress [MPa]', ...
    'Nominal Loading Degree [-]', 'Loading Degree [-]', 'Nominal RH [%]', 'Measured Mean RH [%]'};

columnsNames = {'Time [h]', 'Creep Strain [-]', 'Creep Compliance [MPa^-1]'};
%% Set results folders
% Get list of sample folders
sample_folder = dir(resultsPath);
% Define the valid prefixes
validPrefixes = {'RL', 'LR', 'RT', 'TR', 'LT-EW', 'LT-LW'};
% Filter folders that start with the valid prefixes
sample_folder = sample_folder(...
    cellfun(@(x) any(startsWith(x, validPrefixes)), {sample_folder.name}));

%% Load prony coefficients file
prony_results = load(fullfile(resultsPath,'samples_prony_compliance.mat'));
prony_results = prony_results.samples_results;
%%

for k = 1:length(sample_folder)
    savePath = fullfile(resultsPath,sample_folder(k).name); % path to sample folder
    % Clean existing results files
    excelPath1 = fullfile(savePath,strcat(sample_folder(k).name,'_results.xlsx'));
    if exist(excelPath1, 'file') == 2; delete(excelPath1); end
    % Load data table
    export_file_table = fullfile(savePath,strcat(sample_folder(k).name,'_table.mat'));
    export_table = load(export_file_table); export_table = export_table.export_table;
    % Sort table by RH
    [~, sortIndex] = sort([export_table.RH]);
    export_table = export_table(sortIndex);
    % Get list of samples listed in the table
    samples = {export_table.sample_name}';
    % Get list of results files
    results_file = fullfile(savePath,strcat(samples,'_results.mat'));
    % Convert results data to excel file
    for i = 1:length(results_file)
        filePath = char(results_file(i));
        data = load(filePath);
        % Initialize field names
        scalarValues = {'exp_code','sample_name','sample_type',...
            'thickness_mm','width_mm','area_mm2','duration_h',...
            'nominal_load_N','nominal_stress_MPa','creep_load_N',...
            'creep_stress_MPa','failure_load_N','failure_stress_MPa',...
            'nominal_loading_degree','loading_degree','nominal_RH',...
            'creep_RH'};
        
        % Create a cell array for the Excel sheet
        excelData = {};
        % Place scalar values
        for j = 1:numel(scalarValues)
            field = scalarValues{j};
            excelData{j, 1} = listNames{j}; % Use new name
            if ~strcmp(field, 'nominal_loading_degree') && ~strcmp(field, 'nominal_RH')
                excelData{j, 2} = data.(field);
            elseif strcmp(field, 'nominal_loading_degree')
                index = find(strcmp({export_table.sample_name}, data.sample_name));
                excelData{j, 2} = export_table(index).nominal_loading_degree;
            elseif strcmp(field, 'nominal_RH')
                index = find(strcmp({export_table.sample_name}, data.sample_name));
                excelData{j, 2} = export_table(index).RH;
            end
        end

        % Place KV parameters
        compValues = {'Compliance_1 [MPa^-1]', 'Compliance_2 [MPa^-1]', 'Compliance_3 [MPa^-1]', 'Compliance_4 [MPa^-1]'};
        for j = 1:4
            field = compValues{j};
            excelData{numel(scalarValues)+j, 1} = compValues{j};
            index = find(strcmp({prony_results.sample_name}, data.sample_name));
            excelData{numel(scalarValues)+j, 2} = prony_results(index).comp_i(j);
        end

        % Place arrays below scalar values
        currRow = numel(scalarValues)+6; % Row index starts after scalar values
        % Set creep data to store
        arrayNames = {'time', 'creep_strain', 'creep_compliance'};
        eval_idx = data.strain_eval_idx;
        col.time = data.dt_h(eval_idx(3):end)-data.dt_h(eval_idx(3));
        col.RH = data.measured_RH(eval_idx(3):end);
        el_strain = data.total_axial_strain(eval_idx(3));
        col.creep_strain = data.total_axial_strain(eval_idx(3):end)-el_strain;
        col.creep_load = data.measured_load_N(eval_idx(3):end);
        col.creep_stress = data.measured_stress_MPa(eval_idx(3):end);
        col.creep_compliance = col.creep_strain/data.creep_stress_MPa;
        numRows = length(col.creep_stress);
        
        for j = 1:numel(columnsNames)
            field = arrayNames(j);
            excelData{currRow, j} = columnsNames{j};
            excelData(currRow+1:(currRow+numRows), j) = num2cell(col.(char(field)));
        end
        % Save excel file
        writecell(excelData, excelPath1, 'Sheet', data.sample_name);

    end
    % Check if the file exists
    if exist(excelPath1, 'file') == 2
        fprintf('The file "%s" was successfully saved.\n', strcat(sample_folder(k).name,'_results.xlsx'));
    else
        fprintf('Error: The file "%s" was not saved.\n', strcat(sample_folder(k).name,'_results.xlsx'));
    end
end
disp('Done.');
