function [y_coefs, u_coefs] = util_get_model_tf_coefs(model)
%     if iscell(model.Denominator)
%         y_coefs = real(model.Denominator{1});
%         y_coefs = flip(y_coefs');
%         u_coefs = real(model.Numerator{1});
%         u_coefs = flip(u_coefs');

    y_coefs = flip(model.Denominator');
    u_coefs = flip(model.Numerator');

end