function [impulses_optimized, r_squared_total] = func_optimize_impulses(data_dir, subj, start_event, end_event, iteration, ts, sc, event_markers, impulses_input, model_tf)
%     sc_min = min(sc);
%     sc_tmp = sc - sc_min;
    sid_data = iddata(sc, impulses_input, ts);   
    
    %% convert pruned model to time domain ARX model matrix form
    model = model_tf;
    y = sc;
    n = length(y);    
    % obtain model coefficients in matrix form, iodelay is not applied here
    [A, B] = util_model_tf_to_arx_mat_form(model, n, 0); 
    y_free = util_get_free_resp_using_model(model, sid_data, n);
    % subtract free response from measurement
    y_forced_with_noise = y - y_free;
    y_used = y_forced_with_noise;
    
   
    
    
    %% minimize || A^-1*B*u - y||2
    k = length(model.Denominator); % k is num of y coefs
    
    %% case 2c
    A_new = A(k:end, k:end);  % A needs to be square and nonzero to have inverse
    B_new = B(k:end, k:end);
    C = A_new \ B_new;  % this is A^-1*B
    d = y_used(k:end);
    best_alpha = 0.1; 
    H = C'*C;
    f = -C'*d + best_alpha;
    n_new = n - k + 1;
    x0 = zeros(n_new, 1); % initial value does not matter in this optimization
    lb = zeros(1, n_new);
    [x_fit, fval] = quadprog(H, f,[],[], [], [], lb, [], x0); 
    impulses_optimized = [zeros(k-1, 1); x_fit];

    y_est = util_predict_y_using_arx(model, impulses_optimized, 0);
    sc_pred = y_est + y_free;
    

    %% significant impulses 
    idx_sig = find(impulses_optimized > 0.01);
    num_impulses = length(idx_sig);
    impulses_sum = sum(impulses_optimized);
    
    %% plot and save
    [fig_optimized, r_squared_total] = util_plot_optimized_impulses(subj, start_event, end_event, iteration, ts, sc, impulses_input, sc_pred, impulses_optimized, event_markers, num_impulses, impulses_sum);
    fp_out_plot = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Iteration%d_Step2_OptimizedImpulses.jpg',subj, start_event, end_event, iteration));
    exportgraphics(fig_optimized, fp_out_plot, 'Resolution',300);
    
    fp_out_impulse = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Iteration%d_Step2_OptimizedImpulses.mat',subj, start_event, end_event, iteration));
    save(fp_out_impulse, 'impulses_optimized', 'r_squared_total');
    
end
