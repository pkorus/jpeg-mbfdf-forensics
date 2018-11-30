function jpeg_res = jpeg_rescale(varargin)

    if nargin < 2 || nargin > 3
        error('Invalid number of input arguments.');
    end
    
    jpeg_image = varargin{1};
    quality = varargin{2};
    
    if nargin == 3
        force_round = varargin{3};
    else
        force_round = 1;
    end

    jpeg_res = jpeg_image;

    for k = 1:jpeg_image.image_components
        q_table = jpeg_image.quant_tables{jpeg_image.comp_info(k).quant_tbl_no};
        q_table_n = jpeg_qtable(quality, jpeg_image.comp_info(k).quant_tbl_no - 1, 1);
        if q_table == q_table_n
            continue;
        end
        c_array = jpeg_image.coef_arrays{k};
        for i=8:8:size(c_array,1)
            for j=8:8:size(c_array,2)
                c_array(i-7:i,j-7:j) = c_array(i-7:i,j-7:j) .* q_table ./ q_table_n;
            end
        end
        
        if force_round
            c_array = round(c_array);
        end
        
        jpeg_res.coef_arrays{k} = c_array;
        jpeg_res.quant_tables{jpeg_res.comp_info(k).quant_tbl_no} = q_table_n;
    end

end