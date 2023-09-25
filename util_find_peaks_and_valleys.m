function [peak_locs, peak_vals, valley_locs, valley_vals] = util_find_peaks_and_valleys(sc, ts, threshold)
    fs = 1/ts;
    % get local peaks and valleys
    t = (0:(length(sc)-1)) .* ts;
    t = t';
    [peak_vals, peak_times] = findpeaks(sc,t,'MinPeakProminence',threshold);
    [valley_vals, valley_times] = findpeaks(-sc,t,'MinPeakProminence',threshold);
    valley_vals = - valley_vals;

    if isempty(peak_times) || isempty(valley_times)
        peak_locs = [];
        peak_vals = [];
        valley_locs = [];
        valley_vals = [];
        return 
    end

    % if first peak is before the first valley, add first data point to valleys
    if peak_times(1) < valley_times(1)
        valley_vals = vertcat(sc(1), valley_vals);
        valley_times = vertcat(t(1),valley_times);
    end

%     % if the first peak is within 1 sec, then it's not caused by the first
%     % stimulus, but previous stimuli, so the first pair needs to be removed 
%     if peak_locs(1) < 1
%         peak_vals = peak_vals(2:end);
%         peak_locs = peak_locs(2:end);
%         valley_vals = valley_vals(2:end);
%         valley_locs = valley_locs(2:end);
%     end

    % make sure we have the same number of peaks and valleys    
    len = min(length(peak_times), length(valley_times));
    peak_times = peak_times(1:len);
    peak_vals = peak_vals(1:len);
    valley_times = valley_times(1:len);
    valley_vals = valley_vals(1:len);
    
    % convert time to indices
    peak_locs = int64(peak_times * fs) + 1;
    valley_locs = int64(valley_times * fs) + 1;

    
end