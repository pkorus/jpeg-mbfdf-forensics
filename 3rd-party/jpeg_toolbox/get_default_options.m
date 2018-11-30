function [options] = get_default_options(image_dims)

    options = struct();

    options.progressive_mode = 0;
    options.quality = 100;
    options.subsampling_mode = '4_4_4';
    if image_dims == 3
        options.output_color_mode = 'IMAGE_COLOR';
    else
        options.output_color_mode = 'IMAGE_GREYSCALE';
    end
end