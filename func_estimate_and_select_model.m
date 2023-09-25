function [model_tf, r_squared_total] = func_estimate_and_select_model(data_dir, subj, start_event, end_event, iteration, order, max_iodelay, sc, impulses, ts)
    sid_data = iddata(sc, impulses, ts);    
    model_candidates = [];
    % loop through each combination of poles and zeros
       
    for i = order
        for j = order    % j is typically smaller than i 
            for iodelay = 0:max_iodelay
                % initialcondition has 4 options: zero, estimate, backcast, auto, (auto has the same results as backcast)
                opt = tfestOptions('InitialCondition', 'estimate');
                [model_tf, ic] = tfest(sid_data, i, j, iodelay, 'Ts', ts, opt); 
                [~, r_squared_total, ~, ~, ~, ~, ~] = func_decompose_and_prune_model(subj, start_event, end_event, iteration, ts, model_tf, ic, sc, impulses);
                model_candidates = [model_candidates; [i, j, iodelay, r_squared_total]];
            end
        end
    end


    [~, max_idx] = max(model_candidates(:, 4));
    disp('best model');
    disp(model_candidates(max_idx, :));


    %% save selected model (pruned)
    selected_model_order = model_candidates(max_idx, :);
    np = selected_model_order(1);
    nz = selected_model_order(2);
    iodelay = selected_model_order(3);
    

    opt = tfestOptions('InitialCondition', 'estimate');  
    [model_tf, ic] = tfest(sid_data, np, nz, iodelay, 'Ts', ts, opt); 
    [model_tf, r_squared_total, fig_subsys_pred, subsys_ids, subsys_models, subsys_tau, subsys_gain, subsys_period] = func_decompose_and_prune_model(subj, start_event, end_event, iteration, ts, model_tf, ic, sc, impulses);
                 
    
    fp_out_model = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Iteration%d_Step1_EstimatedModel.mat',subj, start_event, end_event, iteration));
    save(fp_out_model, 'model_tf', 'ic', 'r_squared_total', 'subsys_ids', 'subsys_models', 'subsys_tau', 'subsys_gain', 'subsys_period');
    
    fp_out_plot = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Iteration%d_Step1_ModelDecompAndPred.jpg',subj, start_event, end_event, iteration));
    exportgraphics(fig_subsys_pred, fp_out_plot, 'Resolution',300);
    
    


end

