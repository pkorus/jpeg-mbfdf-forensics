function QF = estimate_quality_factor(qtable, component_no)
% ESTIMATE_QUALITY_FACTOR estimates squality based on quantization table
%   QF = ESTIMATE_QUALITY_FACTOR(QUANTIZATION_TABLE, COMPONENT_NUMBER)

    % Get baseline quantization table
    jpeg_table = jpeg_qtable(50,component_no,1);
    % Compute scaling factor for each coefficient of table
    scaling_factor = (qtable * 100 - 50)./ jpeg_table;
    % Compute average value.
    mean_QF = mean2(scaling_factor);
    
    if mean_QF < 100
        QF = (200 - mean_QF)/2;
    else
        QF = 5000 / mean_QF;
    end
    
    % Check values that are smaller or greater than estimated value (in
    % range [-2,2]).
    
    vec_d = -2:1:2;
    score = zeros(1,length(vec_d));
    
    for i = vec_d
        qtable_err = qtable - jpeg_qtable(round(QF)+i,component_no);
        score(i+3) = sum(sum(qtable_err.^2));
    end
    % Return value which quantization table is the closest representation
    % of input one.
    [~, ind] = min(score);
    QF = round(QF) + vec_d(ind);
end