lena_base = jpeg_read('../../demoset/lena_gray.jpg');
lena_base = jpeg_rescale(lena_base, 85);
% lena_base_save = jpeg_rescale(lena_base, 100);
jpeg_write(lena_base, '/tmp/lena90.jpg');
lena90 = jpeg_read('/tmp/lena90.jpg');

figure;

cumulative = zeros(8);

for jpeg_compression_level=85:95
    lena_recompressed = imread('/tmp/lena90.jpg');
    ber_mat = zeros(8);
    block_num = 0;
    imwrite(lena_recompressed, '/tmp/lena90r.jpg', 'Quality', jpeg_compression_level);
    lena_recompressed = jpeg_read('/tmp/lena90r.jpg');
    lena_recompressed = jpeg_rescale(lena_recompressed, 85);
    diff = double(lena_base.coef_arrays{1} ~= lena_recompressed.coef_arrays{1});
    for i=8:8:size(diff,1)
        for j=8:8:size(diff,2)
            ber_mat = ber_mat + diff(i-7:i,j-7:j);
            block_num = block_num + 1;
        end
    end
    
    cumulative = cumulative + ber_mat;
    
    subplot(3,4,jpeg_compression_level-84);
    surf(flipud(ber_mat/block_num * 100));
    title(['JPEG ' num2str(jpeg_compression_level)]);
    xlabel('X');
    ylabel('Y');
%     axis([1,8,1,8,0,max(max(ber_mat/block_num * 100))*1.1])
    zlabel('BER[%]');
end

subplot(3,4,12);
surf(flipud(cumulative/block_num/11 * 100));
title('All JPEG mean error');
xlabel('X');
ylabel('Y');
zlabel('BER[%]');


