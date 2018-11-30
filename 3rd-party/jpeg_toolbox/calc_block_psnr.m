function psnr = calc_block_psnr(imga, imgb, block_size)
    psnr = zeros(size(imga));
    psnr = psnr(:,:,1);
    block_size_m = block_size - 1;
    
    for i=block_size:block_size:size(imga,1)
        for j=block_size:block_size:size(imga,2)
            psnr(i-block_size_m:i,j-block_size_m:j) = calc_psnr(imga(i-block_size_m:i,j-block_size_m:j),imgb(i-block_size_m:i,j-block_size_m:j));
        end
    end



%     if all(size(imga) == size(imgb)) && size(imga,3) ~= 0
%         if size(imga,3) > 1
%             psnr = zeros(size(imga));
%             for i=1:3
%                 psnr(:,:,i) = calc_block_psnr(imga(:,:,i),imgb(:,:,i),block_size);
%             end  
%         else
%             psnr = zeros(size(imga));
%             block_size_m = block_size - 1;
%             imga = double(im2uint8(imga));
%             imgb = double(im2uint8(imgb));
%             for i=block_size:block_size:size(imga,1)
%                 for j=block_size:block_size:size(imga,2)
%                     psnr(i-block_size_m:i,j-block_size_m:j) = mean2((imga(i-block_size_m:i,j-block_size_m:j)-imgb(i-block_size_m:i,j-block_size_m:j)).^2);
%                 end
%             end
%             
%             psnr = 10*log10(65025./psnr);
%         end
%     else
%         psnr = zeros(size(imga));
%     end
end