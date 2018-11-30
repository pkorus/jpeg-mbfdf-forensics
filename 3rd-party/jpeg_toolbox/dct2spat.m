function image_spat = dct2spat(image_dct, image_quality)

    image_spat = zeros([size(image_dct{1}), length(image_dct)]);
    
    quant_table_Y = jpeg_qtable(image_quality, 0);
    quant_table_Cx = jpeg_qtable(image_quality, 1);
    
    for i = 8:8:size(image_dct{1},1)
        for j = 8:8:size(image_dct{1},2)
            image_spat(i-7:i,j-7:j,1) = image_dct{1}(i-7:i,j-7:j) .* quant_table_Y;
        end
    end
    image_spat(:,:,1) = ibdct(image_spat(:,:,1));
    
    if length(image_dct) > 1
        for g = 2:length(image_dct)
            for i = 8:8:size(image_dct{g},1)
                for j = 8:8:size(image_dct{g},2)
                    image_spat(i-7:i,j-7:j,g) = image_dct{g}(i-7:i,j-7:j) .* quant_table_Cx;
                end
            end
            image_spat(:,:,g) = ibdct(image_spat(:,:,g));
        end
        rgb_img = uint8(ycbcr2rgb((image_spat + 128)/255)*255);
        image_spat = rgb_img;
    else
        image_spat = uint8(image_spat + 128);
    end

end