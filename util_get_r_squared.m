function r_squared = util_get_R_squared(y_measured, y_predict)
%     residual = y_measured - y_predict;
%     
% %     var_residual = var(residual);
% %     var_measured = var(y_measured);
% %     
% %     var_percent = 1 - var_residual / var_measured;
% %     disp(var_percent);

    %%% https://en.wikipedia.org/wiki/Explained_variation
    %%% https://en.wikipedia.org/wiki/Fraction_of_variance_unexplained
    
    ss_residual = sum((y_measured - y_predict).^2);
    %disp(ss_residual);
   
    ss_total = sum((y_measured - mean(y_measured)).^2);
    %disp(ss_total);
    
    r_squared = 1 - ss_residual/ss_total;
    
    
end