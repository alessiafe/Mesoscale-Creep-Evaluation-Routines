function prony_results = save_samples_prony(data)
    
    prony_results = struct(); % initialize empty struct
    %fields = fieldnames(data); % get fields names
    fields = {'exp_code', 'sample_type', 'sample_name', 'RH', 'loading_deg','creep_stress',...
        'time', 'creep_strain', 'creep_compliance','gamma_i', 'tau_i'};
    % Loop over each element (row) of the fields
    for j = 1:length(fields)
        field_name = fields{j};
        for i = 1:length(data.(fields{1}))
            % Check if the field contains a single value (e.g., a string)
            if strcmp(field_name,'creep_compliance')
                prony_results(i).(fields{j}) = 1/data.creep_stress{i}.*data.creep_strain{i};
            elseif length(data.(fields{j})) == 1 || ischar(data.(fields{j}))
                % Repeat the single value for each row
                prony_results(i).(fields{j}) = data.(fields{j});
            else
                % Assign the data as rows in the new struct
                if strcmp(field_name,'gamma_i')
                    prony_results(i).comp_i = 1./data.(fields{j}){i};
                else
                    prony_results(i).(fields{j}) = data.(fields{j}){i};
                end
            end
        end
    end

end