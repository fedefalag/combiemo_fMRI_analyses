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
opt = facelocalizer_getOption();

% the cdirectory with this script becomes the current directory
WD = pwd;

% we add all the subfunctions that are in the sub directories
addpath(genpath(WD));

% In case some toolboxes need to be added the matlab path, specify and uncomment
% in the lines below
toolbox_path = '/Users/falagiarda/GitHub/combiemo_fMRI_analyses/lib';
addpath(genpath(fullfile(toolbox_path)));

checkDependencies();

% % copy raw folder into derivatives folder
bidsCopyRawFolder(opt, 1)
% 
 

% % preprocessing
 bidsSTC(opt);
 bidsSpatialPrepro(opt);
 bidsSmoothing(funcFWHM, opt);

% subject level Univariate
bidsFFX('specifyAndEstimate', opt, funcFWHM);
bidsFFX('contrasts', opt, funcFWHM);

% group level univariate
funcFWHM=6;
conFWHM = 8;
bidsRFX('smoothContrasts', opt, funcFWHM, conFWHM);

% group level univariate
% BIDS_RFX(1, 6, 6);
%BIDS_RFX(2, 6, 6);

%BIDS_Results(6, 6, opt, 0);

% subject level multivariate
% isMVPA=1;
% BIDS_FFX(1, 6, opt, isMVPA);
% BIDS_FFX(2, 6, opt, isMVPA);
% make4Dmaps(6,opt)
