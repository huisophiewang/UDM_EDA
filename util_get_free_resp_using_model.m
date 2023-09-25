function y_free = util_get_free_resp_using_model(model_tf, sid_data, num_sample)
    X0 = findstates(model_tf, sid_data);
    model_ss = ss(model_tf);
    A = model_ss.A;
    C = model_ss.C;    
    k = length(X0);
    y_free = zeros(num_sample, 1);
    X = zeros(k, num_sample);
    X(:,1) = X0;
    for i=1:num_sample
        X(:,i+1) = A * X(:,i);
        y_free(i) = C * X(:,i);
    end
end