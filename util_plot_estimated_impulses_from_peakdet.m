function fig_peakdet = util_plot_estimated_impulses_from_peakdet(subj_id, start_event, end_event, sc, ts, impulses, peakdet_threshold, event_markers, peak_locs, peak_vals, valley_locs, valley_vals)
    figure;
    set(gcf, 'Position',  [300, 550, 1500, 400]);
    % plot sc 
    t = (0:(length(sc)-1)) .* ts;
    t = t';
    p1 = plot(t, sc);
    xlabel('t [sec]');
    ylabel('sc [\mus]');
    hold on;
    % plot peaks and valleys
    plot(t(peak_locs), peak_vals, 'r.','MarkerSize',10, 'MarkerFaceColor','r');
    plot(t(valley_locs), valley_vals,'g.','MarkerSize',10, 'MarkerFaceColor','g');
    p2 = plot(t, impulses, 'b');
    
    event_time_indices = find(event_markers == 1);
    y_range = get(gca,'YLim');
    p3 = plot([t(event_time_indices(1)), t(event_time_indices(1))], [y_range(1), y_range(2)], 'r', 'LineStyle', ':');
    for i=2:length(event_time_indices)
        plot([t(event_time_indices(i)), t(event_time_indices(i))], [y_range(1), y_range(2)], 'r', 'LineStyle', ':');
    end
    
    num_impulses = length(find(impulses > 0));
    sum_amps = sum(impulses);
    title_str = sprintf('Subj: %d, Event%d-%d\nNum impulses: %d (threshold: %.2f), Sum of All Impulse Amps: %.2f', subj_id, start_event, end_event, num_impulses, peakdet_threshold, sum_amps);
    title(title_str, 'Interpreter', 'none');
    legend([p1 p2 p3], 'sc', 'initial impulses', 'events');
    
    fig_peakdet = gcf;
end