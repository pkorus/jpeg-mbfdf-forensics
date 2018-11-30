function image = dct_quant(image, q_mat)

    dct_matrix = dctmtx(8);
    dct_matrix_t = dct_matrix';

    [h, w] = size(image);

    for i=1:8:h
        for j=1:8:w
            image(i:i+7,j:j+7) = round((dct_matrix * image(i:i+7,j:j+7) * dct_matrix_t)./q_mat);
        end
    end


end