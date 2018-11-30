restoredefaultpath;

verbose = true;
paths = strsplit(genpath('./'),{':',';'});

for i=1:length(paths)
    if numel(paths{i}) > 2 && exist(paths{i}, 'dir') && isempty(strfind(paths{i}, './.git'))
        % Skip directories without useful files
        if numel(dir([paths{i} '/*.m'])) + numel(dir([paths{i} '/*.' mexext()])) > 0
            if verbose; fprintf('Adding to path: %s\n', paths{i}); end;
            addpath(paths{i});
        else
            if verbose; fprintf('Skipping: %s (no M-files or MEX files found)\n', paths{i}); end
        end
    end
end

clearvars;

if ~exist('cache', 'dir')
    mkdir('cache');
end
