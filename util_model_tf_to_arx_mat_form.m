function [coef_mat_A, coef_mat_B] = util_model_tf_to_arx_mat_form(model_tf, num_sample, apply_io_delay)
    coef_mat_A = zeros(num_sample, num_sample);
    coef_mat_B = zeros(num_sample, num_sample);
    [y_coefs, u_coefs] = util_get_model_tf_coefs(model_tf);
    num_y_coef = length(y_coefs);
    num_u_coef = length(u_coefs);
    for i=num_y_coef:num_sample
        coef_mat_A(i, i-num_y_coef+1:i) = y_coefs;
    end
    for k=num_u_coef:num_sample
        coef_mat_B(k, k-num_u_coef+1:k) = u_coefs;
    end
    
    % this mat applies io delay
    if apply_io_delay
        %delay = model_idtf.IODelay; delay needs to be > 0, cannot be 0
        delay = 20;
        shift_mat = circshift(eye(num_sample), delay);
        for i=1:num_sample
            shift_mat(i, i:end) = 0;
        end
        coef_mat_B = coef_mat_B * shift_mat;
    end
end