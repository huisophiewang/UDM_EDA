function [model_tf_pruned, r_squared_total, fig_subsys_pred, subsys_ids, subsys_models, subsys_tau, subsys_gain, subsys_period] = func_decompose_and_prune_model(subj, start_trial, end_trial, iteration, ts, model_tf, ic, sc, estimated_impulses)    
    % convert to continuous tf model
    iodelay = model_tf.IODelay;    
    try
        model_tf_c = d2c(model_tf);   
    catch ME
        disp(ME.message);
        model_tf_pruned = [];
        r_squared_total = 0;
        fig_subsys_pred = [];
        subsys_ids = [];
        subsys_models = [];
        subsys_tau = [];
        subsys_gain = []; 
        return
    end
    [r, p, k] = residue(model_tf_c.Numerator, model_tf_c.Denominator);
    
   
    % separate all subsys poles into real poles and complex poles
    complex_poles = [];
    real_poles = [];
    for i=1:length(p)
        if isreal(p(i))
            real_poles = [real_poles; [p(i), r(i)]];
        else
            a = real(p(i));
            b = imag(p(i));
            c = real(r(i));
            d = imag(r(i));
            complex_poles = [complex_poles; [a,b,c,d]];
        end
    end
    
    % keep only the odd index of complex poles, 
  
    num_pairs = int16(size(complex_poles, 1)/2);
    idx = (1:num_pairs)*2 - 1;
    complex_poles = complex_poles(idx,:);

    
    % compute real pole subsys model params (time constant, gain) for later pruning
    if isempty(real_poles)
        real_poles_tau = [];
        real_poles_gain = [];
    else
        real_poles_tau = -1./real_poles(:,1);
        real_poles_gain = real_poles(:,2);
    end
    

    
    % compute complex pole subsys model params (time constant, gain, period) for later pruning
    if isempty(complex_poles)
        complex_poles_tau = [];
        complex_poles_period = [];
        complex_poles_gain = [];
    else     
        complex_poles_tau = -1./complex_poles(:,1);
        complex_poles_period = 2*pi./complex_poles(:,2);
        complex_poles_gain = 2*complex_poles(:,3);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% pruning round 1 (based on gain and period)
    % subsys pruning needs to follow the order in [r, p] returned by residue(), otherwise may have error
 
    subsys_models = [];
    subsys_ids = {};
    subsys_tau = [];
    subsys_gain = [];
    subsys_period = [];
    r_all = [];
    p_all = [];
    
    % select complex poles (period > threshold)
    num_complex = size(complex_poles, 1);
    if num_complex > 0
        for k=1:num_complex
            period = complex_poles_period(k);
            %gain = complex_poles_gain(k);
            % remove subsys with period larger than 1 sec, because it's likely to be noise
            if period > 1
                p1 = complex(complex_poles(k,1), complex_poles(k,2));
                p2 = complex(complex_poles(k,1), -complex_poles(k,2));
                p_all = [p_all;p1;p2];
                r1 = complex(complex_poles(k,3), complex_poles(k,4));
                r2 = complex(complex_poles(k,3), -complex_poles(k,4));
                r_all = [r_all;r1;r2];

                % convert one complex pole subsys to tranfer function model
                subsys_tf = util_zpg_to_tf_model([r1;r2], [p1;p2], iodelay, ts);
                subsys_models = [subsys_models;subsys_tf];
                subsys_ids = [subsys_ids; sprintf('C%d', k)];
                subsys_tau = [subsys_tau; complex_poles_tau(k)];
                subsys_gain = [subsys_gain; complex_poles_gain(k)];
                subsys_period = [subsys_period; period];
            else
                disp('complex subsys removed due to small period');
            end
        end
    end
    
    % select all real poles 
    num_real = size(real_poles, 1);
    if num_real > 0
        for k=1:num_real
            %gain = real_poles_gain(k);
            %if (abs(gain) > gain_threshold)
            p = complex(real_poles(k,1));
            r = complex(real_poles(k,2));  
            p_all = [p_all;p];
            r_all = [r_all;r];
            % convert one real pole subsys to tranfer function model
            subsys_tf = util_zpg_to_tf_model(r, p, iodelay, ts);
            subsys_models = [subsys_models;subsys_tf];
            subsys_ids = [subsys_ids; sprintf('R%d', k)];
            subsys_tau = [subsys_tau; real_poles_tau(k)];
            subsys_gain = [subsys_gain; real_poles_gain(k)];                                  

        end
    end
    
    %% save pruned model
    model_tf_pruned = util_zpg_to_tf_model(r_all, p_all, iodelay, ts);
    
    [fig_subsys_pred, r_squared_total] = util_plot_subsys_model_prediction(subj, start_trial, end_trial, iteration, '',...
        sc, estimated_impulses, ts, model_tf_pruned, ic, subsys_models, subsys_ids, subsys_tau, subsys_gain, subsys_period);
  

end