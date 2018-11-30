function features = extractMBFDFeatures(C, modes)
% features = extractMBFDFeatures(C, modes)
%
% Extracts mode-based first digit features from the supplied array of 
% JPEG coefficients. 
%
% -------------------------------------------------------------------------
% Written by Paweł Korus while with SZU and AGH
% Current version: November 2018
% Contact: pkorus [at] agh [dot] edu [dot] pl
% -------------------------------------------------------------------------

    fd = @(x) floor(x ./ 10.^floor(log10(x)));

    zz = [9 2 17 10 3 25 18 ...
         11 4 33 26 19 12 5 41 ...
         34 27 20 13 6 49 42 35 ...
         28 21 14 7 57 50 43 36 ...
         29 22 15 8 58 51 44 37 ...
         30 23 16 59 52 45 38 31 ...
         24 60 53 46 39 32 61 54 ...
         47 40 62 55 48 63 56 64];
     
    zz = zz(1:modes);

    blocks = ceil(size(C)/8);

    coefficients = zeros(prod(blocks), modes);

    for bx = 1:blocks(2)
        for by = 1:blocks(1)
            i = (by-1)*blocks(1) + bx;
            B = abs(C((by-1)*8+1:by*8, (bx-1)*8+1:bx*8));
            coefficients(i,:) = B(zz);
        end
    end

    features = zeros(modes, 9);
    first_digits = fd(coefficients);

    for m = 1:modes
        digits = first_digits(:,m); 
        digits(isnan(digits)) = [];
        if isempty(digits) 
            continue
        end
        digits = uint8(digits);
        pi = zeros(1,9, 'uint32');
        for d = digits'
            pi(d) = pi(d) + 1;
        end
        features(m, :) = double(pi)/sum(pi);
    end

    features = features(:);
end