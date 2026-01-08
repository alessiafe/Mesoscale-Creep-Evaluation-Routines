
function sol = opt_strain_prony(ydata, tdata, N, gamma_0, tau_0, obj)
    % Fit creep compliance data to Prony series. Create an optimization problem to
    % find the Prony coefficients (gamma_i) by least-squares fitting, i.e.
    % by minimizing the sum of square errors between the observed and the
    % predicted values.
    % Inputs:
    % - ydata = creep compliance array
    % - tdata = time array [h]
    % - N = num. of KV elements
    % - gamma_0 = initial value of gamma_i (Prony coeff.)
    % - tau_0 = relaxation time array
    % Optional input:
    % - obj = type of optimization object -> Sum of Squares Error (SSE)
    %   (absolute or relative)

    %% Set default type of error calculation
    switch nargin
        case 5
            obj = 'rel'; % type of optimization obj -> relative SSE
        case 6
        otherwise
            error('Only 7 inputs are accepted.')
    end

    
    %}
    %% Run fitting process
    % Initialize array of optimization variables
    gamma_i = optimvar('gamma_i', N, 'LowerBound', 0); % N x gamma_i >0
    % Create optimization problem
    fun = @(gamma_i) (sum(1./gamma_i) - sum(1./gamma_i' .* exp(-tdata./tau_0),2)); % function to fit
    response = fcn2optimexpr(fun,gamma_i); % convert function to optimization expression     
    % Set object of least-squares fitting -> SSE
    if strcmp(obj,'abs')
        obj = sum((response - ydata).^2); % sum of squares of errors
    elseif strcmp(obj,'rel')
        SSE = 0;
        for i=1:length(response)
            if ydata(i) == 0; value = 0;
            else; value = ((response(i)-ydata(i))/ydata(i))^2; end % sum of squares of relative errors
            SSE = SSE + value;
        end
        obj = SSE;
    end
    
    lsqproblem = optimproblem("Objective",obj); % create optimization problem of object = SSE
    x0.gamma_i = gamma_0; % set initial value of optimization variables
    options = optimoptions('lsqnonlin', 'MaxFunctionEvaluations', 500); % set evaluations limit
    [sol,~] = solve(lsqproblem, x0,'Options', options); % solve optimization problem
    sol.tau_i = tau_0; % add pre-defined tau_i to solution
end