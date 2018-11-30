function jpeg_image = subsample(jpeg_image, mode)

    if jpeg_image.image_components == 3

        vertical_subsampling_factor = 2;
        horizontal_subsampling_factor = 2;

        switch mode
            case '4_4_4'
            case '4_2_0'
                vertical_subsampling_factor = 1;
                horizontal_subsampling_factor = 1;
            case '4_2_2'
                horizontal_subsampling_factor = 1;
            case '4_4_0'
                vertical_subsampling_factor = 1;
        end

        if vertical_subsampling_factor == 1
            for i=2:3
                filtered = conv2(jpeg_image.coef_arrays{i}, [1; 1]/2);
                jpeg_image.coef_arrays{i} = filtered(2 : 2 : size(filtered, 1),:);
                jpeg_image.comp_info(i).v_samp_factor = 1;
            end
            jpeg_image.comp_info(1).v_samp_factor = 2;
        end

        if horizontal_subsampling_factor == 1
            for i=2:3
                filtered = conv2(jpeg_image.coef_arrays{i}, [1 1]/2);
                jpeg_image.coef_arrays{i} = filtered(:, 2 : 2 : size(filtered, 2));
                jpeg_image.comp_info(i).h_samp_factor = 1;
            end
            jpeg_image.comp_info(1).h_samp_factor = 2;
        end  

    end

end