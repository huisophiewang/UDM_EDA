function [fig_subsys_pred, r_squared_total] = util_plot_subsys_model_prediction(subj, start_event, end_event, iteration, note, sc, impulses, ts, model_tf, ic, subsys_models, subsys_ids, subsys_tau, subsys_gain, subsys_period)
    figure;
    set(gcf, 'Position',  [100, 500, 1500, 400]);
    n = length(sc);
    t = (0:(n-1)) * ts;
    p1 = plot(t, sc, 'b');
    xlabel('t [sec]');
    ylabel('sc [\mus]');
    hold on;
    p2 = plot(t, impulses, 'r');
    yline(0, 'k');
    
    model = model_tf;
    np = length(model.Denominator)-1;
    nz = length(model.Numerator)-1;
    iodelay = model.IODelay;
    sid_data = iddata(sc, impulses, ts);   

    
    k = length(subsys_models);
    y_subsys = zeros(n, k);
    for i=1:k
        y_subsys(:,i) = util_predict_y_using_arx(subsys_models(i), impulses, 1);      
    end
    %y_free = util_get_free_resp_using_ic(ic, n);
    y_free = util_get_free_resp_using_model(model, sid_data, n);
    
    y_forced = sum(y_subsys, 2);
    y_total = y_forced + y_free;
    sum_y_total = sum(y_total);
    r_squared_total = util_get_r_squared(sc, y_total);
    

    plot_handles = [p1 p2];
    plot_legends = {'y (measured sc)'; 'v (estimated SNA)'};

    count_comp = 0;
    for i=1:length(subsys_models)
        handle = plot(t, y_subsys(:,i));      
        model_id = subsys_ids{i};
        tau = subsys_tau(i);
        gain = subsys_gain(i);
        plot_handles = [plot_handles handle];
        if contains(model_id, 'R')
            plot_legends = [plot_legends; sprintf('%s (tau=%.2f, r=%.2f)', model_id, tau, gain)];
        end
        if contains(model_id, 'C')
            count_comp = count_comp + 1;
            period = subsys_period(count_comp);
            plot_legends = [plot_legends; sprintf('%s (tau=%.2f, r=%.2f, T=%.2f)', model_id, tau, gain, period)];
        end
    end
    
    
    p3 = plot(t, y_free, 'c');
    %p4 = plot(t, y_forced, 'c');
    p5 = plot(t, y_total, 'm');    
    plot_handles = [plot_handles [p3 p5]];
    plot_legends = [plot_legends; {'y free'; 'y pred (total)'}];
    

    legend(plot_handles, plot_legends, 'Location', 'northeast');
    
    title_str = sprintf('Subj: %d, Event%d-%d, Iteration: %d\nPoles and Zeros: (%d, %d), IODelay: %d, Total R Squared: %.4f', subj, start_event, end_event, iteration, np, nz, iodelay, r_squared_total);

    title(title_str, 'Interpreter', 'none');
     

    fig_subsys_pred = gcf;
end