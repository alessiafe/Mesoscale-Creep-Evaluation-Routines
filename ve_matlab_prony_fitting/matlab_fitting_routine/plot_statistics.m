
function plot_statistics(data, prony_param)

    % Plot mean
    tdata_fit = linspace(0,max(cellfun(@(x) x(end), data.time)),1000)';
    fun = @(gamma_i, tau_i) (sum(1./gamma_i) - sum(1./gamma_i' .* exp(-tdata_fit./tau_i'),2));  
    responsedata = fun(prony_param(:,1), data.tau_i{1});
    plot(tdata_fit, responsedata, '-', 'Color', 'red', 'LineWidth', 2); hold on
    % Plot 95% conf. int.
    for k=2:size(prony_param,2)
        responsedata = fun(prony_param(:,k), data.tau_i{1});
        plot(tdata_fit, responsedata, '--', 'Color', 'red', 'LineWidth', 2); hold on
    end

end