close all;
clear all;

%% input file (.csv)
% col1: t - timestamp in seconds, 
% col2: sc - skin conductance in micro-Siemons
% col3: event - event markers (1 is event, 0 is no event)
cur_dir = pwd;
data_dir = fullfile(cur_dir, "UDM_EDA", "example_data");
fp_in =  fullfile(data_dir, 'S19_SC_Block1.csv');


%% required input parameters
fs = 10;            % sampling freq of EDA data
ts = 1/fs;          % sampling interval
subj_id = 19;        % subject id 
start_event = 1;    % start event id
end_event = 31;     % end event id

%% model hyperparameters (set with default values)
iter_stop_threshold = 0.005;     % threshold used to stop EM iteration
iter_max = 10;                   % max iteration 
order = 4;                       % selected model order (4th order)
max_iodelay = 5;                 % max iodelay used in model selection


%% get initial impulses
func_get_initial_impulses(data_dir, fp_in, subj_id, start_event, end_event, ts);


%% start EM 
% load data and initial impulses
fp_in_data = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Data_and_InitialImpulses.mat',subj_id, start_event, end_event));
load(fp_in_data, 'sc', 'event_markers', 'initial_impulses');
r_squared_all_iter = [];
for iter=1:iter_max
    if iter == 1
        estimated_impulses = initial_impulses;
    else
        fp_in_impulse = fullfile(data_dir, sprintf('Subj%d_Event%dto%d_Iteration%d_Step2_OptimizedImpulses.mat', subj_id, start_event, end_event, iter-1));
        load(fp_in_impulse, 'impulses_optimized');
        estimated_impulses = impulses_optimized;            
    end
    
    % M step: estimate model parameters
    [model_tf, r_squared_total1] = func_estimate_and_select_model(data_dir, subj_id, start_event, end_event, iter, order, max_iodelay, sc, estimated_impulses, ts);
    
    % E step: estimate impulses
    [impulses_optimized, r_squared_total2] = func_optimize_impulses(data_dir, subj_id, start_event, end_event, iter, ts, sc, event_markers, estimated_impulses, model_tf);
    r_squared = r_squared_total2;
    r_squared_all_iter = [r_squared_all_iter; r_squared];

    % stop iteration when the increase of R^2 is smaller than threshold
    if iter > 1 
        r_square_increase = r_squared_all_iter(end) - r_squared_all_iter(end-1);
        if (r_square_increase > 0) && (r_square_increase < iter_stop_threshold)
            break
        end
    end
end



