function mat_seg = util_cut_data_by_event(fp_in, start_event, end_event, sec_before_start_event)
    mat = readmatrix(fp_in);
    t = mat(:,1);  % col1: timestamp (in seconds)
    sc = mat(:,2);  % col2: skin conductance values
    event = mat(:,3);  % col3: event markers, 1 if it is an event, 0 otherwise


    event_indices = find(event == 1);
    num_events = length(event_indices);
    
    if start_event == 1
        start_t = t(1);
    else
        start_t = t(event_indices(start_event)) - sec_before_start_event;
    end
    
    if end_event == num_events
        end_t = t(end);
    else
        end_t = t(event_indices(end_event+1));
    end
    indices = find((t >= start_t) & (t < end_t));
    
    
    sc_seg = sc(indices);
    event_seg = event(indices);
    t_seg = t(indices);
    mat_seg = horzcat(t_seg, sc_seg, event_seg);
    

end

