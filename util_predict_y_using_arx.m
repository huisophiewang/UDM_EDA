%% the goal is to test if the coefficients of the transfer function model can be used for predicting y accurately 
% it returns the same result as sim without intial condition, this is straightforward and clear, sim is opaque 
% initial condition is not added here, so it is actually predicting forced response

function y_pred = util_predict_y_using_arx(model_idtf, input_u, apply_io_delay)
    n = length(input_u);
    %[y_coefs, u_coefs] = util_get_tf_model_coefs(model_idtf);
    y_coefs = flip(model_idtf.Denominator');
    u_coefs = flip(model_idtf.Numerator');
    
    num_y_coef = length(y_coefs);
    num_u_coef = length(u_coefs);
    
    % k is padding
    if apply_io_delay
        iodelay = model_idtf.IODelay;        
    else
        iodelay = 0;     
    end
    
    % compared with no iodelay, iodelay can be achieved by either
    % adding more zeros before u, or adding more zeros before y_pred,
    % we are doing the latter here
    k = max(num_u_coef, num_y_coef);  % padding is added because the y(1) needs previous y and u
    y_pred = [zeros(k, 1); zeros(iodelay, 1); zeros(n, 1)];
    
    % add padding to u
    if isrow(input_u)
        input_u = input_u';
    end
    u = [zeros(k, 1); input_u];
    
    for i=1:n
        x_part = dot(u(k+i-(num_u_coef-1):k+i), u_coefs);
        ar_part = - dot(y_pred(k+iodelay+i-(num_y_coef-1):k+iodelay+i-1), y_coefs(1:num_y_coef-1));
        y_pred(k+iodelay+i) =  ar_part + x_part;
    end
    
    % remove the first k samples
    y_pred = y_pred(k+1:k+n);
end