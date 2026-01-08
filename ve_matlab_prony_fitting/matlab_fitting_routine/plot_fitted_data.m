
function plot_fitted_data(data)

    figure; %subplot(1, 2, 1);
    cmap = colormap('cool');
    step = fix(length(cmap)/length(data.sample_name));
    %% Plot axial strain
    plot_title = strcat(data.sample_type,'-',string(data.RH),'%RH-',string(data.loading_deg),'LD');
    legend_arr = cell(length(data.sample_name)*2, 1); % initialize cell array
    for k=1:length(data.sample_name)
        tdata_fit = linspace(0,data.time{k}(end),1000)';
        fun = @(gamma_i, tau_i) (sum(1./gamma_i) - sum(1./gamma_i' .* exp(-tdata_fit./tau_i'),2));
        responsedata = fun(data.gamma_i{k}, data.tau_i{k});
        plot(tdata_fit, responsedata, '-', 'Color', cmap(k*step,:)); hold on
        plot(data.time{k}, data.creep_strain{k}/data.creep_stress{k}, '*', 'Color', cmap(k*step,:)); hold on
        legend_arr{2*k-1} = strcat(data.sample_name{k},' - Fitted Curve');
        legend_arr{2*k} = strcat(data.sample_name{k},' - Original Data');
    end
    xlabel('Time [h]');
    ylabel('Creep compliance [1/MPa]');
    legend(legend_arr,'Location','southeast');
    title(plot_title);

end