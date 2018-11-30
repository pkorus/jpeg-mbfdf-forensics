function maps = detectForgeryMBFDFMultiscale(filename, overlap, block_sizes, use_qf_oblivious_model)
% detectForgeryMBFDFMultiscale(filename, overlap, block_sizes)
%
% Generates multi-scale tampering probability maps using a detector based on
% mode-based first digit features. The detector operates on a sliding-window 
% manner and uses SVM to classify the current block as either singly
% or doubly compressed.
%
% Input Parameters:
% 
%  - filename        - self explanatory
%
%  - overlap         - controls the overlap of the sliding window. Example
%                      values:
%                      1.0   - maximal overlap, the window will be moved by
%                              8 px (one image block).
%                      0.5   - medium overlap, the window will be moved by
%                              half of the window size.
%                      0.0   - no overlap, window moveed by full window size
%
%  - block_sizes     - vector of the desired analysis window sizes, e.g., 
%                      [16, 32, 64, 128]
%
%  - use_qf_oblivious_model - Use a generic, quality-oblivious SVM model; 
%                             see details in readme.md; (true or false)
% 
% The function will look for the relevant SVM models in:
% 
%   ./data/svm_20_modes/{WINDOW-SIZE}/{JPEG-QUALITY}.mat
%
% The JPEG quality is estimated automatically from the input file (based on 
% the standard IJG quantization tables).
%
% Output:
%
% The function returns a structure with fields:
%  - candidate     - probability maps (full window attribution)
%  - cpa_candidate - probability maps (central pixel attribution)
%  - reliability   - corresponding indication of saturated (or empty) regions
%  - block         - analysis window sizes
%
% For more information about the detector, please see [1,2].
%
% [1] P. Korus and J. Huang, Multi-Scale Fusion for Improved Localization 
%     of Malicious Tampering in Digital Images, IEEE Transactions on Image 
%     Processing, Vol. 25, Issue 3, 2016
% [2] P. Korus, Large-Scale and Fine-Grained Evaluation of Popular JPEG 
%     Forgery Localization Schemes, arXiv
%
% -------------------------------------------------------------------------
% Written by Paweł Korus while with SZU and AGH
% Current version: November 2018
% Contact: pkorus [at] agh [dot] edu [dot] pl
% -------------------------------------------------------------------------


    if ~exist('use_qf_oblivious_model', 'var')
        use_qf_oblivious_model = false;
    end
    
    if ~any(overlap == [0 0.5 1.0]) 
        error('forensicsFramework:invalidInput', 'The overlap should be 0, 0.5, or 1');
    end

    % Parameters
    modes = 20;

    % Check if the file is a JPEG file
    if ~contains(lower(filename), '.jpg') && ~contains(lower(filename), '.jpeg')
        error('forensicsFramework:invalidInput', 'The file should have a .jpeg or .jpg extension: %s.', filename);
    end
    
    % Load image
    jpeg = jpeg_read(filename);
    C = jpeg.coef_arrays{1};
    
    % Estimate JPEG quality level - ideally should be detected from the file
    if use_qf_oblivious_model
        qlevel = 0;
    else
        qlevel = estimate_quality_factor(jpeg.quant_tables{1}, 0);
    end
    
    % Make sure SVM models are available
    for i = 1:numel(block_sizes)
        block = block_sizes(i);
        model_filename = sprintf('data/svm_20_modes/%d/%d.mat', block, qlevel);
        if ~exist(model_filename, 'file')
            error('forensicsFramework:fileNotFound', 'There is no SVM model for the requested settings (%s)! Consider using a quality-oblivious model.', model_filename);
        end
    end

    if nargin < 3
        block_sizes = [16, 32, 48, 64, 80, 96, 112, 128];
    end
    E = cell(size(block_sizes));
    P = cell(size(block_sizes));
    R = cell(size(block_sizes));
    B = zeros(size(block_sizes));
    
    % Loop over analysis windows and run detection
    for i = 1:numel(block_sizes)
        block = block_sizes(i);
        data = load(sprintf('data/svm_20_modes/%d/%d.mat', block, qlevel), 'model');
        local_overlap = max(1, round((1-overlap)*floor(block/8)));
        [E{i}, P{i}, R{i}] = detectForgeryMBFDF(C, modes, floor(block/8), local_overlap, data.model, true);
        B(i) = block;
    end    
    maps.candidate = E;
    maps.reliability = P;
    maps.cpa_candidate = R;    
    maps.block = B;
end
