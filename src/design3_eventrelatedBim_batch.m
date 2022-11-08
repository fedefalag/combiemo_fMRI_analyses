%   __  ____  ____     _      _    _
%  / _)(  _ \(  _ \   | |    / \  | )
% ( (_  )___/ )___/   | |_  / _ \ | \
%  \__)(__)  (__)     |___||_/ \_||__)
%
% Thank you for using the CPP lap pipeline - version 0.0.3.
%
% Current list of contributors includes
%  Mohamed Rezk
%  Rémi Gau
%  Olivier Collignon
%  Ane Gurtubay
%  Marco Barilari
%
% Please cite using the following DOI:
%  https://doi.org/10.5281/zenodo.3554332
%
% For bug report, suggestions for improvements or contributions see our github repo:
%  https://github.com/cpp-lln-lab/CPP_BIDS_SPM_pipeline

clear;
clc;

%% Run batches
opt = design3_eventrelatedBim_getOption();

% the cdirectory with this script becomes the current directory
WD = pwd;

% we add all the subfunctions that are in the sub directories
addpath(genpath(WD));

% In case some toolboxes need to be added the matlab path, specify and uncomment
% in the lines below
toolbox_path = fullfile(WD, '..', 'lib');
assert(isfolder(toolbox_path))
addpath(genpath(toolbox_path));

checkDependencies();

funcFWHM = 2;

% subject level Univariate
bidsFFX('specifyAndEstimate', opt, 2);
bidsFFX('contrasts', opt, 2);

% last two arguments set to zeros in order not to delete beta and tmaps
bidsConcatBetaTmaps(opt, funcFWHM, 0, 0);
