% cosmo MVPA

function cosmomvpaFuncRoiCrossValidation_auditory(opt, funcFWHM)

% be very verbose please
cosmo_warning('on')

% get ROI paths
%derivativesDirCheck = regexp(opt.derivativesDir, filesep ,'split');

%if ~strcmp(derivativesDirCheck(length(derivativesDirCheck)), 'derivatives')
    
%    derivativesDir = fullfile(opt.derivativesDir, '..');
    
%else
    
    derivativesDir = opt.derivativesDir;
    
%end

% combine these two with subj nr in the middle
pathLoc = opt.locDir;
pathROI = opt.maskDir;

% set output dir
pathOutput = derivativesDir;

%% Loop through groups and subjects

[group, opt] = getData(opt);

%subjects = opt.subjects;

for iGroup = 1:length(group)

%for iSub = 1:group(iGroup).numSub
for iSub = 1:length(opt.subjects)
                
        % set structure array for keeping the results
        accu = struct( ...
            'sub', [], ...
            'group', [], ...
            'roiArea', [], ...
            'roiDimension', [], ...
            'roiNbVoxels', [], ...
            'ffxResults', [], ...
            'conditions', [], ...
            'modality', [], ...
            'accuracy', [], ...
            'predictors', []);
        
        % get FFX path
        subID = opt.subjects{iSub};
        groupName = 'withinSubj';
        
        pathData = strcat(opt.derivativesDataDir,'sub-',subID,opt.dataExtensionDir,num2str(funcFWHM),'/');
        
        fprintf(['\n For subj: ' subID '\n\n']);
        
        % loop through ffxResults (beta and tmaps)
        
        count = 1;
        
        for iFfxResult = 1:length(opt.cosmomvpa.ffxResults)
            
            fprintf(['\n For ffx result: ' opt.cosmomvpa.ffxResults{iFfxResult} '\n\n']);
            
            % set the 4D result image
            resultsImage = fullfile(pathData,['4D_' opt.cosmomvpa.ffxResults{iFfxResult} '_' num2str(funcFWHM) '.nii']);
            
            % loop through ROI dimension and area
            
            for iRoi = 1:length(opt.cosmomvpa.rois)
                
%                 % set ratio to keep depending on the ROI and 4D map
%                 if strcmp(opt.cosmomvpa.ffxResults{iFfxResult}, 'beta')
%                  opt.cosmomvpa.ratioToKeep = opt.cosmomvpa.ratioToKeepBetas;
%                 elseif strcmp(opt.cosmomvpa.ffxResults{iFfxResult}, 't_maps')
%                  opt.cosmomvpa.ratioToKeep = opt.cosmomvpa.ratioToKeepTmaps;
%                 end
                
                opt.cosmomvpa.feature_selection_ratio_to_keep = opt.cosmomvpa.ratioToKeep;
                
                % load ROI masks for a specific dimension
                roiPattern = fullfile(strcat(pathLoc,'sub-',subID,pathROI,'sub-',subID,'_',opt.cosmomvpa.rois(iRoi),'_fmask_FWHM-2_',opt.thre(iRoi),'.nii'));
                
                roiFileNames = dir(roiPattern{1});
                
                for i = 1:length(roiFileNames)
                    
                    roiMasks{i} = roiFileNames(i).name;  %#ok<*AGROW>
                    
                end
                
                %% ROI MVPA analyses
                
                for iMask = 1:length(roiMasks)
                    
                    % define brain mask
                    mask = roiPattern{1};
                    
                    roiName = regexp(roiMasks{iMask}, '_', 'split');
                    
                    fprintf(['\nMask: ' roiName{1} '\n\n']);
                    
                    %% 5 emotions
                    stim = [1 2 3 4 5]; % neutral, disgust, fear, happiness, sadness
                    
                    labels = {'1','2','3','4','5'};
                    
                    conditionsToTest = {'fiveClassDecoding'};
                    
                    for iConditionToTest = 1:length(conditionsToTest)
                        
                        %%% loop through modalities
                        %for iModality = 1:numel(opt.cosmomvpa.modalities)
                            
                            %fprintf([' Modality: ' opt.cosmomvpa.modalities{iModality} '\n\n']);
                            
                            % define the data structure
                            ds = cosmo_fmri_dataset(resultsImage, 'mask', mask);
                          
                            %cosmo_disp(ds);
                            
                            % getting rid off zeros
                            zero_msk = all(ds.samples == 0, 1);
                            
                            ds = cosmo_slice(ds, ~zero_msk, 2);
                            
                            mask_size = size(ds.samples, 2);
                            
                            % set chunks, targets and labels
                            
                            ds = setTargetsChunksLabels(opt, ds, stim, labels);
                            
                            %switch opt.cosmomvpa.modalities{iModality}
                                
                                %case 'auditory'
                                    
                                    % 4 Motion
                                    
                                    % 5 emotions
                                    if strcmp(conditionsToTest{iConditionToTest}, 'fiveClassDecoding')
                                        ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 2 | ds.sa.targets == 3 | ds.sa.targets == 4 | ds.sa.targets == 5);
%                                         % Left vs. Right
%                                     elseif strcmp(conditionsToTest{iConditionToTest}, 'LeftvsRight')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 4 | ds.sa.targets == 2);
%                                         % Up vs Down
%                                     elseif strcmp(conditionsToTest{iConditionToTest}, 'UpvsDown')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 3);
                                    end
                                    
%                                 case 'visual'
%                                     
%                                     % 4 Motion
%                                     if strcmp(conditionsToTest{iConditionToTest}, 'FourDirectionsDecoding')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 5 | ds.sa.targets == 6 | ds.sa.targets == 7 | ds.sa.targets == 8);
%                                         % Left vs. Right
%                                     elseif strcmp(conditionsToTest{iConditionToTest}, 'LeftvsRight')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 8 | ds.sa.targets == 6);
%                                         % Up vs Down
%                                     elseif strcmp(conditionsToTest{iConditionToTest}, 'UpvsDown')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 5 | ds.sa.targets == 7);
%                                     end
%                                     
%                                 case 'bimodal'
%                                     
%                                     % 4 Motion
%                                     if strcmp(conditionsToTest{iConditionToTest}, 'FourDirectionsDecoding')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 9 | ds.sa.targets == 10 | ds.sa.targets == 11 | ds.sa.targets == 12);
%                                         % Left vs. Right
%                                     elseif strcmp(conditionsToTest{iConditionToTest}, 'LeftvsRight')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 12 | ds.sa.targets == 10);
%                                         % Up vs Down
%                                     elseif strcmp(conditionsToTest{iConditionToTest}, 'UpvsDown')
%                                         ds = cosmo_slice(ds, ds.sa.targets == 9 | ds.sa.targets == 11);
%                                     end
%                                     
%                          end
                            
                            % remove constant features
                            ds = cosmo_remove_useless_data(ds);
                            
                            % partitioning, for test and training : cross validation
                            partitions = cosmo_nfold_partitioner(ds);                            
                                                       
                            % ROI mvpa analysis
                            [pred, accuracy] = cosmo_crossvalidate(ds, ...
                                @cosmo_meta_feature_selection_classifier, ...
                                partitions, opt.cosmomvpa);
                            
                            % store results to be saved
                            accu = storeResults(accu, count, ...
                                subID, ...
                                groupName, ...
                                roiName{1}, ...
                                opt.cosmomvpa.rois(iRoi), ...
                                mask_size, ...
                                opt.cosmomvpa.ffxResults{iFfxResult}, ...
                                conditionsToTest{iConditionToTest}, ...
                                opt.cosmomvpa.modalities, ...
                                accuracy, ...
                                pred);
                            
                            count = count + 1;
                            
                            fprintf(['  - condition: ' conditionsToTest{iConditionToTest} ', accuracy: ' num2str(accuracy) '\n\n\n']);
                            
                        %end
                        
                    end
                    
%                     %% 2 axes by 3 modalities
%                     stim = [1 2 3 4 5];
%                     
%                     labels = {'auditory_vert', 'auditory_hor', 'auditory_vert', 'auditory_hor' ...
%                         'visual_vert', 'visual_hor', 'visual_vert', 'visual_hor', ...
%                         'bimodal_vert', 'bimodal_hor', 'bimodal_vert', 'bimodal_hor' };
%                     
%                     conditionsToTest = {'HorizontalvsVertical'};
%                     
%                     for iConditionToTest = 1:length(conditionsToTest)
%                         
%                         % loop through modalities
%                         for iModality = 1:numel(opt.cosmomvpa.modalities)
%                             
%                             fprintf([' Modlaity: ' opt.cosmomvpa.modalities{iModality} '\n\n']);
%                             
%                             % define the data structure
%                             ds = cosmo_fmri_dataset(resultsImage, 'mask', mask);
%                             
%                             % getting rid off zeros
%                             zero_msk = all(ds.samples == 0, 1);
%                             
%                             ds = cosmo_slice(ds, ~zero_msk, 2);
%                             
%                             mask_size = size(ds.samples, 2);
%                             
%                             % set chunks, targets and labels
%                             
%                             ds = setTargetsChunksLabels(opt, ds, stim, labels);
%                             
%                             switch opt.cosmomvpa.modalities{iModality}
%                                 
%                                 case 'auditory'
%                                     
%                                     ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 2);
%                                     
%                                 case 'visual'
%                                     
%                                     ds = cosmo_slice(ds, ds.sa.targets == 3 | ds.sa.targets == 4);
%                                     
%                                 case 'bimodal'
%                                     
%                                     ds = cosmo_slice(ds, ds.sa.targets == 5 | ds.sa.targets == 6);
%                                     
%                             end
%                             
%                             % remove constant features
%                             ds = cosmo_remove_useless_data(ds);
%                             
%                             % partitioning, for test and training : cross validation
%                             partitions = cosmo_nfold_partitioner(ds);
%                             
%                             % ROI mvpa analysis
%                             [pred, accuracy] = cosmo_crossvalidate(ds, ...
%                                 @cosmo_meta_feature_selection_classifier, ...
%                                 partitions, opt.cosmomvpa);
%                             
%                             % store results to be saved
%                             accu = storeResults(accu, count, ...
%                                 subID, ...
%                                 groupName, ...
%                                 roiName{1}, ...
%                                 opt.cosmomvpa.roiDimension(iRoiDimension), ...
%                                 mask_size, ...
%                                 opt.cosmomvpa.ffxResults{iFfxResult}, ...
%                                 conditionsToTest{iConditionToTest}, ...
%                                 opt.cosmomvpa.modalities{iModality}, ...
%                                 accuracy, ...
%                                 pred);
%                             
%                             count = count + 1;
%                             
%                             fprintf(['  - condition: ' conditionsToTest{iConditionToTest} ', accuracy: ' num2str(accuracy) '\n\n\n']);
%                             
%                         end
%                         
%                     end
%                     
%                     %% 3 modalities
%                     stim = [1 1 1 1 ...
%                         2 2 2 2 ...
%                         3 3 3 3];
%                     
%                     labels = {'auditory', 'auditory', 'auditory', 'auditory' ...
%                         'visual', 'visual', 'visual', 'visual', ...
%                         'bimodal', 'bimodal', 'bimodal', 'bimodal' };
%                     
%                     conditionsToTest = {'ThreeModalitiesDecoding', ...
%                         'AuditoryvsVisual', ...
%                         'AuditoryvsBimodal', ...
%                         'VisualvsBimodal'};
%                     
%                     for iConditionToTest = 1:length(conditionsToTest)
%                         
%                         % define the data structure
%                         ds = cosmo_fmri_dataset(resultsImage, 'mask', mask);
%                         
%                         % getting rid off zeros
%                         zero_msk = all(ds.samples == 0, 1);
%                         
%                         ds = cosmo_slice(ds, ~zero_msk, 2);
%                         
%                         mask_size = size(ds.samples, 2);
%                         
%                         % set chunks, targets and labels
%                         
%                         ds = setTargetsChunksLabels(opt, ds, stim, labels);
%                         
%                         switch conditionsToTest{iConditionToTest}
%                             
%                             case 'ThreeModalitiesDecoding'
%                                 
%                                 ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 2 | ds.sa.targets == 3);
%                                 
%                             case 'AuditoryvsVisual'
%                                 
%                                 ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 2);
%                                 
%                                 
%                             case 'AuditoryvsBimodal'
%                                 
%                                 ds = cosmo_slice(ds, ds.sa.targets == 1 | ds.sa.targets == 3);
%                                 
%                             case 'VisualvsBimodal'
%                                 
%                                 ds = cosmo_slice(ds, ds.sa.targets == 2 | ds.sa.targets == 3);
%                                 
%                         end
%                         
%                         % remove constant features
%                         ds = cosmo_remove_useless_data(ds);
%                         
%                         % partitioning, for test and training : cross validation
%                         partitions = cosmo_nfold_partitioner(ds);
%                         
%                         % ROI mvpa analysis
%                         [pred, accuracy] = cosmo_crossvalidate(ds, ...
%                             @cosmo_meta_feature_selection_classifier, ...
%                             partitions, opt.cosmomvpa);
%                         
%                         % store results to be saved
%                         accu = storeResults(accu, count, ...
%                             subID, ...
%                             groupName, ...
%                             roiName{1}, ...
%                             opt.cosmomvpa.roiDimension(iRoiDimension), ...
%                             mask_size, ...
%                             opt.cosmomvpa.ffxResults{iFfxResult}, ...
%                             conditionsToTest{iConditionToTest}, ...
%                             'allModalities', ...
%                             accuracy, ...
%                             pred);
%                         
%                         count = count + 1;
%                         
%                         fprintf(['  - condition: ' conditionsToTest{iConditionToTest} ', accuracy: ' num2str(accuracy) '\n\n\n']);
%                         
%                     end    
                    
                end
                
            end
            
        end
        
        %set names output file 
        savefileMat = fullfile(pathOutput, ...
            ['sub-', subID, ...
            '_task-', opt.taskName, ...
            '_cosmomvpa_FWHM-', num2str(funcFWHM), ...
            '_', datestr(now, 'yyyymmdd'), '.mat' ]);
        
        savefileCsv = fullfile(pathOutput, ...
            ['sub-', subID, ...
            '_task-', opt.taskName, ...
            '_cosmomvpa_FWHM-', num2str(funcFWHM), ...
            '_', datestr(now, 'yyyymmdd'), '.csv' ]);        
        
        save(savefileMat, 'accu');
        
        writetable(struct2table(accu), savefileCsv)
        
end
end
    
end

function ds = setTargetsChunksLabels(opt, ds, stim, labels)

% set chunks (runs by trial_type), target (stimulation type - modality),
% names (stimulation type name)
trialsPerRun = length(stim) * opt.cosmomvpa.nbTrialRepetition;

chunks = repmat((1:opt.cosmomvpa.nbRun)', 1, opt.cosmomvpa.nbTrialRepetition)';
chunks = chunks(:);
chunks = repmat(chunks, trialsPerRun, 1);

targets = repmat(stim', 1, opt.cosmomvpa.nbRun)';
targets = targets(:);

labels = repmat(labels', 1, opt.cosmomvpa.nbRun)';
labels = labels(:);

ds.sa.targets = targets;
ds.sa.chunks = chunks;
ds.sa.labels = labels;

end


function  accu = storeResults(accu, count, subID, groupName, roiName, ...
    roiDimension, mask_size, ffxResult, conditionName, modality, accuracy, pred)

% store results
accu(count).sub = subID;
accu(count).group = groupName;
accu(count).roiArea = roiName;
accu(count).roiDimension = roiDimension;
accu(count).roiNbVoxels = mask_size;
accu(count).ffxResults = ffxResult;
accu(count).conditions = conditionName;
accu(count).modality = modality;
accu(count).accuracy = accuracy;
accu(count).predictors = pred;

end