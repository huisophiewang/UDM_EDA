function func_get_initial_impulses(data_dir, fp_in, subj_id, start_event, end_event, ts)
    peakdet_threshold=0.01;
    data_mat = util_cut_data_by_event(fp_in, start_event, end_event, 0);
    sc = data_mat(:,2);
    event_markers = data_mat(:,3);
    initial_impulses = zeros(length(sc),1);
    [peak_locs, peak_vals, valley_locs, valley_vals] = util_find_peaks_and_valleys(sc, ts, peakdet_threshold);
    if ~isempty(peak_locs) && ~isempty(valley_locs)
        impulse_amps = peak_vals - valley_vals;
        impulse_locs = valley_locs;
        initial_impulses(impulse_locs) = impulse_amps;

        fig_peakdet = util_plot_estimated_impulses_from_peakdet(subj_id, start_event, end_event, sc, ts, initial_impulses, peakdet_threshold, event_markers, peak_locs, peak_vals, valley_locs, valley_vals);
        fp_out_jpg = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Data_and_InitialImpulses.jpg',subj_id, start_event, end_event));
        exportgraphics(fig_peakdet, fp_out_jpg, 'Resolution', 300);

        fp_out_data = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Data_and_InitialImpulses.mat',subj_id, start_event, end_event));
        save(fp_out_data, 'sc', 'event_markers', 'initial_impulses', 'peak_locs', 'peak_vals', 'valley_locs', 'valley_vals');
    end
    
end


