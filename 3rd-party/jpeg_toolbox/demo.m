im = imread('lena512.bmp');
im = im(1:end-2,1:end-2,:);

options = get_default_options(im);
% options.subsampling_mode = '4_4_4';
% options.subsampling_mode = '4_4_0';
% options.subsampling_mode = '4_2_2';
options.subsampling_mode = '4_2_0';
% options.progressive_mode = 1;
options.progressive_mode = 0;
options.output_color_mode = 'IMAGE_COLOR';
% options.output_color_mode = 'IMAGE_GREYSCALE';
options.quality = 1;

[psnr ssim compression_ratio output_file_size] = jpeg_save(im, 'lena_color.jpg', options);

fprintf('Output file size: %d bytes\n', output_file_size);
fprintf('Compression ratio: %.2f\n', compression_ratio);
fprintf('PSNR/SSIM: %.2fdB/%.4f\n', psnr,ssim);
