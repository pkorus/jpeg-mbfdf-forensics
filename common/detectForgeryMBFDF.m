function [E, P, R] = detectForgeryMBFDF(C, modes, bs, bsk, model, inpaint_missing)
% detectForgeryMBFDF(C, modes, bs, bsk, model, inpaint_missing)
%
% Generates a tampering probability map based on sliding-window analysis of the 
% mode-based first digit features. 
%
% Input Parameters:
% 
%  - C		     - array of JPEG coefficients (luminance comp.)
%
%  - modes           - number of DCT modes for MBFDF feature extraction (must
%                      match the supplied SVM model). 
%
%  - bs              - analysis window size (in JPEG blocks), e.g., use 8 for a
%                      64 x 64 px window
%
%  - bsk             - sliding window stride (in JPEG blocks), e.g., use 1 for 
%                      maximal window overlap, and bs for non-overlapping windows
%
%  - model           - SVM model structure (libsvm)
%
%  - inpaint_missing - if the sliding-window does not reach certain areas (e.g., 
%                      when bsk > 1) the tampering localization scores will be 
%                      missing. They can be filled as 0.5 or by simple inpainting
%                      depending on the value of this flag.
% 
% The function returns the tampering probability map (E) and a corresponding map 
% indicating saturated (or empty) regions of the image (P). 
%
% -------------------------------------------------------------------------
% Written by Paweł Korus while with SZU and AGH
% Current version: November 2018
% Contact: pkorus [at] agh [dot] edu [dot] pl
% -------------------------------------------------------------------------

    if mod(bs, bsk) ~= 0
        error('mbfdf:argChk', 'Unsupported block skip - needs to divide block size');
    end

    if bsk > bs
        error('mbfdf:argChk', 'Block skip cannot exceed block size');
    end
    
    if nargin < 6
        inpaint_missing = false;
    end

    maxbx = size(C,2)/8;
    maxby = size(C,1)/8;
    
    E = zeros(maxby, maxbx);
    W = zeros(maxby, maxbx);
    P = zeros(maxby, maxbx); % Unreliable area predictor (flat / saturated)

    maxfx = ceil((maxbx - bs + 1)/bsk);
    maxfy = ceil((maxby - bs + 1)/bsk);
    features = zeros(maxfx*maxfy, 9*modes);
    saturation = zeros(maxfx*maxfy, 1);
    
    % Helper for coefficient selection to calc mean AC coeff (sat. scores)
    zz = [    64     2     4     7    11    16    22    29;
               3     5     8    12    17    23    30    37;
               6     9    13    18    24    31    38    44;
              10    14    19    25    32    39    45    50;
              15    20    26    33    40    46    51    55;
              21    27    34    41    47    52    56    59;
              28    35    42    48    53    57    60    62;
              36    43    49    54    58    61    63    64];
    
    selection_window = repmat(zz, bs, bs);
    selection_window = selection_window <= modes;
    
    bx = 1;
    fi = 1;
    while bx <= maxbx - bs + 1
        by = 1;
        while by <= maxby - bs + 1
            B = abs(C((by-1)*8+1:(by+bs-1)*8, (bx-1)*8+1:(bx+bs-1)*8));     
            features(fi,:) = extractMBFDFeatures(B, modes);
            saturation(fi,:) = mean(B(selection_window));
            by = by + bsk;
            fi = fi + 1;
        end
        bx = bx + bsk;
    end

    [~, ~, probs] = svmpredict(ones(size(features,1),1), features, model, '-q -b 1');

    ptypes = ceil(bs/bsk)*ceil(bs/bsk);
    prototype = zeros(ptypes,2);
    si = 1;
    for s1 = 0:bsk:bs-1
        for s2 = 0:bsk:bs-1
            prototype(si,:) = [s1 s2];
            si = si + 1;
        end
    end
    for bx = 1:maxbx
        for by = 1:maxby
            % Determine indices of relevant examples - for overlapping windows
            cands = repmat([bx by], ptypes, 1) - prototype;
            cands = ceil(cands/bsk);
            v = 0;
            n = 0;
            s = 0;
            for si = 1:ptypes
                if cands(si,1) > 0 && cands(si,2) > 0 && cands(si,1) <= maxfx && cands(si,2) <= maxfy
                    fi = (cands(si,1)-1)*maxfy + cands(si,2);
                    v = v + probs(fi, 2);
                    s = s + saturation(fi);
                    n = n + 1;
                end
            end
            E(by,bx) = v/n;
            P(by,bx) = s/n;
            W(by,bx) = n;
        end
    end
    
    if bsk > 1 && any(any(isnan(E)))
        if inpaint_missing
            E = inpaint_nans(E);
            P = inpaint_nans(P);
            E(E < 0) = 0;
            E(E > 1) = 1;
            P(P < 0) = 0;
            P(P > 1) = 1;
        else
            E(isnan(E)) = 0.5;
            P(isnan(P)) = 0.5;
        end
    end 
    
    E = single(E);
    P = single(P);
    R = single(reshape(probs(:,2), [maxfy maxfx]));

end