function [fig_optimized, r_squared_total] = util_plot_optimized_impulses(subj, start_trial, end_trial, iteration, ts, sc_seg, impulses_seg, sc_pred, impulses_optmized, event_markers_seg, num_imp, u_est_sum)
    figure;
    set(gcf, 'Position',  [300, 550, 1500, 400]);
    hold on;
    n = length(sc_seg);
    t = (0:(n-1)) * ts;
    t = t';
    p1 = plot(t, sc_seg);    
    p2 = plot(t, impulses_seg, 'g');    
    p3 = plot(t, impulses_optmized, 'r');
    p4 = plot(t, sc_pred, 'm');
    r_squared_total = util_get_r_squared(sc_seg, sc_pred);
    
    % plot events
    event_time_indices = find(event_markers_seg == 1);
    y_range = get(gca,'YLim');
    p5 = plot([t(event_time_indices(1)), t(event_time_indices(1))], [y_range(1), y_range(2)], 'r', 'LineStyle', ':');
    for i=2:length(event_time_indices)
        plot([t(event_time_indices(i)), t(event_time_indices(i))], [y_range(1), y_range(2)], 'r', 'LineStyle', ':');
    end
    title_str = sprintf('Subj: %d, Event%d-%d, Iteration: %d\nNum of Impulses(>0.01): %d, Sum of Total Impulse Amps: %.2f\nPrediction R Squared using Optimized u: %.4f', subj, start_trial, end_trial, iteration, num_imp, u_est_sum, r_squared_total);
    title(title_str, 'Interpreter', 'none');
    legend([p1 p2 p3 p4 p5], 'sc measured', 'v input', 'v optimized', 'sc pred', 'events');
    xlabel('t [sec]');
    ylabel('sc [\mus]');
    
    fig_optimized = gcf;

end

