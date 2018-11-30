windows = [32, 64, 128];

dirname = './samples';
files = dir(sprintf('%s/*.JPG', dirname));

fprintf('Found %d samples files\n', numel(files));

images_y = numel(files);
images_x = numel(windows)+1;

detections = cell(1, numel(files));

for i = 1:numel(files)
    fprintf('  Processing %s (%d/%d)\n', files(i).name, i, numel(files));
    filepath = sprintf('%s/%s', dirname, files(i).name);

    detections{i} = detectForgeryMBFDFMultiscale(filepath, 0.5, windows, true);

    image = imread(filepath);
    subplot(images_y, images_x, 1 + images_x * (i-1));
    imsc(image, sprintf('Tampered image (%s)', strrep(files(i).name, '_', '\_')));
    
    for j = 1:numel(detections{i}.block)
        subplot(images_y, images_x, 1 + j + images_x * (i-1));
        imsc(1 - detections{i}.candidate{j}, sprintf('Localization result (%d)', detections{i}.block(j)));
    end    
end
    

