function jpeg_image = get_jpeg_struct(image, options)

im_h = size(image,1);
im_w = size(image,2);
im_cmp = size(image,3);

source_colors = im_cmp;

%% Detecting image colormode conversion options

if isfield(options,'output_color_mode')
    if strcmp(options.output_color_mode, 'IMAGE_GREYSCALE')
        im_cmp = 1;
    elseif strcmp(options.output_color_mode, 'IMAGE_COLOR')
        im_cmp = 3;
    else
        error('Unrecognized output color mode');
    end
else
    im_cmp = size(image,3);
end

if im_cmp == 3
    im_cs = 2;
else
    im_cs = 1;
end

%% Creating jpeg_struct

fields = {'image_width','image_height','image_components','image_color_space','jpeg_components','jpeg_color_space','comments','coef_arrays','quant_tables','optimize_coding','progressive_mode'}';
val = {im_w, im_h, im_cmp, im_cs, im_cmp, im_cmp,cell(0), cell(1,im_cmp), cell(1,im_cs),1,options.progressive_mode}';

jpeg_image = cell2struct(val,fields);

for i=1:im_cs
    jpeg_image.quant_tables{i} = jpeg_qtable(options.quality, i-1, 1); % Truncated (max 255) table of quantization 
    jpeg_image.ac_huff_tables(i) = struct('counts',zeros(1,16),'symbols',zeros(1,256)); 
    jpeg_image.dc_huff_tables(i) = struct('counts',zeros(1,16),'symbols',zeros(1,256)); %??
end

for i=1:im_cmp
    % Components information
    if i == 1
        q_table_num = 1;
    else
        q_table_num = 2;
    end
    jpeg_image.comp_info(i) = struct('component_id',i,'h_samp_factor',1,'v_samp_factor',1,'quant_tbl_no',q_table_num,'dc_tbl_no',q_table_num,'ac_tbl_no',q_table_num);
end

%% YCrCb

if im_cmp == 3
    if source_colors == 1
        jpeg_image.coef_arrays{1} = image(:,:,1) - 128;
        jpeg_image.coef_arrays{2} = zeros(size(image(:,:,1)));
        jpeg_image.coef_arrays{3} = zeros(size(image(:,:,1)));
    else
        jpeg_image.coef_arrays{1} = 0.299*image(:,:,1) + 0.587*image(:,:,2) + 0.114*image(:,:,3) - 128;
        jpeg_image.coef_arrays{2} = -0.168736*image(:,:,1) - 0.331264*image(:,:,2) + 0.5*image(:,:,3);
        jpeg_image.coef_arrays{3} = 0.5*image(:,:,1) - 0.418688*image(:,:,2) - 0.081312*image(:,:,3);
    end
else
    if source_colors == 1
        jpeg_image.coef_arrays{1} = image(:,:,1) - 128;
    else
        jpeg_image.coef_arrays{1} = 0.299*image(:,:,1) + 0.587*image(:,:,2) + 0.114*image(:,:,3) - 128;
    end
end

