function prony_results = save_general_prony(data)
    
    prony_results = struct(); % initialize empty struct
    %fields = fieldnames(data); % get fields names
    fields = {'sample_type', 'RH', 'avg_creep_stress','loading_deg'...
        'avg_comp_i', 'low_comp_i', 'up_comp_i', 'tau_i'};
    % Loop over each element (row) of the fields
    for j = 1:length(fields)
        field_name = fields{j};
        % Check if the field contains a single value (e.g., a string)
        if contains(field_name,'creep_stress')
            prony_results.(fields{j}) = median([data.creep_stress{:}]);
        elseif contains(field_name,'comp_i')
            prony_results.(fields{j}) = 1./data.prony_param(:,j-4);
        elseif contains(field_name,'RH')
            prony_results(1).(fields{j}) = data.(fields{j})(1);
        elseif length(data.(fields{j})) == 1 || ischar(data.(fields{j}))
            % Repeat the single value for each row
            prony_results.(fields{j}) = data.(fields{j});
        else
            prony_results(1).(fields{j}) = data.(fields{j}){1};
        end
    end

end