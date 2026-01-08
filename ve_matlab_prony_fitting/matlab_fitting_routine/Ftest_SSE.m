function SSE = Ftest_SSE(ydata, tdata, sol)
    % Calculate the sum of squares error (SSE) between observed and
    % predicted values for given Prony coefficients.
    % Inputs:
    % - ydata = creep compliance array
    % - tdata = time array [h]
    % - sol = Prony series parameters (tau_i and gamma_i) to calculate
    %   predicted data

    %% Calculate predicted values
    tau_i = sol.tau_i; % extract tau_i pre-defined values
    fun = @(gamma_i) (sum(1./gamma_i) - sum(1./gamma_i' .* exp(-tdata./tau_i),2)); % function to fit
    yprony = fun(sol.gamma_i); % calculate predicted values
    %% Calculate SSE
    SSE = 0; % initialize SSE
    for i=1:length(yprony)
        if ydata(i) == 0; value = 0;
        else; value = ((yprony(i)-ydata(i))/ydata(i))^2; end % relative SSE
        SSE = SSE + value;
    end
end