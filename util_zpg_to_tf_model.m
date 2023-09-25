function model_tf = util_zpg_to_tf_model(subsys_r, subsys_p, iodelay, ts)
    [numerator, denominator] = residue(subsys_r, subsys_p, []);
    % sometimes numerator or denominator has small complex component, need
    % to be convert to real
    numerator = real(numerator);
    denominator = real(denominator);
    subsys_tf_c = tf(numerator, denominator);
    model_tf = c2d(subsys_tf_c, ts);
    model_tf.IODelay = iodelay;
    model_tf = idtf(model_tf);
end