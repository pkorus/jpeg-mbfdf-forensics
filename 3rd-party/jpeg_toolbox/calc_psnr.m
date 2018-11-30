function psnr = calc_psnr(imga, imgb)
    psnr = 0;
    if size(imga,3) == size(imgb,3)
        if all(size(imga) == size(imgb))
            if size(imga,3) > 1
                impFactor = [0.299 0.587 0.114];
                psnr = 0;
                for i=1:size(imga,3)
                    psnr = psnr + impFactor(i) * calc_psnr(imga(:,:,i),imgb(:,:,i));
                end
            else
                imga = double(im2uint8(imga));
                imgb = double(im2uint8(imgb));
                psnr = 10*log10(65025/mean2((imga-imgb).^2));
            end
        end
    else
        if size(imga,3) == 1 && size(imgb,3) == 3
            imgb = rgb2gray(imgb);
            psnr = calc_psnr(imga, imgb);
        end
        if size(imgb,3) == 1 && size(imga,3) == 3
            imga = rgb2gray(imga);
            psnr = calc_psnr(imga, imgb);
        end
    end
end