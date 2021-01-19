% (C) Copyright 2020 Remi Gau, Marco Barilari

function opt = getOption()
    % returns a structure that contains the options chosen by the user to run
    % slice timing correction, pre-processing, FFX, RFX.

    if nargin < 1
        opt = [];
    end

    % task to analyze
    opt.taskName = [];

    % we stay in native space (that of the T1)
    opt.space = 'individual';

    % The directory where the data are located
    opt.dataDir = [];

    % specify the model file that contains the contrasts to compute
    opt.model.file =  [];

    % specify the result to compute
    opt.result.Steps(1) = struct( ...
                                 'Level',  'subject', ...
                                 'Contrasts', struct( ...
                                                     'Name', [], ...
                                                     'Mask', false, ...
                                                     'MC', 'FWE', ...
                                                     'p', 0.05, ...
                                                     'k', 0, ...
                                                     'NIDM', true));

    %% DO NOT TOUCH
    opt = checkOptions(opt);
    saveOptions(opt);

end
