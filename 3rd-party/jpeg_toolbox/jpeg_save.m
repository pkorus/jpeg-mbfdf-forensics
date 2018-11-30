function [ varargout ] = jpeg_save( varargin )
%   JPEG_SAVE(image, path, options) 
%This function allows to save any graphic from Matlab to JPEG
%file. Inpust must be RGB or Grayscale uint8 matrix. Options that can be
%set are: Quality of an image, subsampling, progressive mode, output color
%mode. Get default options for the image by typing:
%   get_default_options(image)
% Last argument is optional. If not set default options will be used.
% Last argument (options) is cell with fields:
%   quality - 1-100
%   subsampling_mode - 4_4_4,4_2_0,4_4_0,4_2_2
%   progressive_mode - 0,1
%   output_color_mode - IMAGE_COLOR, IMAGE_GRAYSCALE

if nargin < 2
    error('Not enough input arguments') ;
elseif nargin > 3
    error('Too many input arguments') ;
elseif nargin == 3
    options = varargin{3};
else
    options = get_default_options(size(varargin{1},3));
end

image_path = varargin{2};

image = double(varargin{1});

%% Creating JPEG struct (RGB->YCrCb,Color mode conversion)

jpeg_image = get_jpeg_struct(image, options);


%% Downsampling

if jpeg_image.jpeg_components > 1
    jpeg_image = subsample(jpeg_image, options.subsampling_mode);
end


%% Block filling

for i = 1:length(jpeg_image.coef_arrays)
    v_diff = ceil(size(jpeg_image.coef_arrays{i},1)/8)*8 - size(jpeg_image.coef_arrays{i},1);
    h_diff = ceil(size(jpeg_image.coef_arrays{i},2)/8)*8 - size(jpeg_image.coef_arrays{i},2);
    
    if v_diff > 0
        jpeg_image.coef_arrays{i} = [jpeg_image.coef_arrays{i}; imresize(jpeg_image.coef_arrays{i}(end,:),[v_diff, size(jpeg_image.coef_arrays{i},2)], 'nearest')];
    end
    if h_diff > 0
        jpeg_image.coef_arrays{i} = [jpeg_image.coef_arrays{i} imresize(jpeg_image.coef_arrays{i}(end,:),[size(jpeg_image.coef_arrays{i},1),h_diff], 'nearest')];
    end
end



%% DCT and quantization to a designated quality level

for i=1:jpeg_image.jpeg_components
    jpeg_image.coef_arrays{i} = dct_quant(jpeg_image.coef_arrays{i}, jpeg_image.quant_tables{jpeg_image.comp_info(i).quant_tbl_no});
end


%% Saving file

jpeg_write(jpeg_image, image_path);


if nargout > 0
    compressed_image = imread(image_path);
    varargout{1} = calc_psnr(compressed_image,uint8(image));
    if nargout > 2
        varargout{2} = ssim_index(compressed_image,uint8(image));
    end
    if nargout > 3
        compressed_file_info = dir(image_path);
        varargout{3} = numel(image)/compressed_file_info.bytes;
        if nargout == 4
            varargout{4} = compressed_file_info.bytes;
        end
    end
end

end




