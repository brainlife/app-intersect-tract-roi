function [] = dtiIntersect()

if ~isdeployed
    disp('loading path')

    %for IU HPC
    addpath(genpath('/N/u/brlife/git/vistasoft'))
    addpath(genpath('/N/u/brlife/git/encode'))
    addpath(genpath('/N/u/brlife/git/jsonlab'))
    addpath(genpath('/N/u/brlife/git/spm'))
    addpath(genpath('/N/u/brlife/git/wma_tools'))

    %for old VM
    addpath(genpath('/usr/local/vistasoft'))
    addpath(genpath('/usr/local/encode'))
    addpath(genpath('/usr/local/jsonlab'))
    addpath(genpath('/usr/local/spm'))
    addpath(genpath('/usr/local/wma_tools'))
end

% Set top directory
topdir = pwd;

% make outdir
outdir = fullfile(pwd,'wmc');
mkdir(outdir);

% Load and parse configuration file
config = loadjson('config.json');
intersect_type = config.intersect_type;

% load wmc
load(config.wmc)
original_classification = classification;

% parse and create ROIs
roiName =  split(config.roi_name)
for irn = 1:length(roiName)
% dtiRoiFromNifti(fullfile(config.rois,sprintf('%s.nii.gz',roiName)),[],fullfile(topdir,'intersect_roi'),'.mat');

%roi = load('intersect_roi.mat');

% load tck
wbFG = fgRead(config.track);

% intersect
for ifg = 1:length(original_classification.names)
	tractFG.name = original_classification.names{ifg};
	tractFG.colorRgb = wbFG.colorRgb;
    	display(sprintf('%s',tractFG.name))
	indexes = find(original_classification.index == ifg);
	tractFG.fibers = wbFG.fibers(indexes);
	[~,~,keep] = dtiIntersectFibersWithRoi([],{intersect_type},config.minimum_distance,roi.roi,tractFG);
	classification.index(indexes(~keep)) = 0;
end

% make fg_classified structure
fg_classified = bsc_makeFGsFromClassification_v4(classification,wbFG);

%% Save output
save('output.mat','classification','fg_classified','-v7.3');

%% create tracts for json structures for visualization
tracts = fg2Array(fg_classified);

mkdir('tracts');

% Make colors for the tracts
%cm = parula(length(tracts));
cm = distinguishable_colors(length(tracts));
for it = 1:length(tracts)
   tract.name   = strrep(tracts{it}.name, '_', ' ');
   all_tracts(it).name = strrep(tracts{it}.name, '_', ' ');
   all_tracts(it).color = cm(it,:);
   tract.color  = cm(it,:);

   %tract.coords = tracts(it).fibers;
   %pick randomly up to 1000 fibers (pick all if there are less than 1000)
   fiber_count = min(1000, numel(tracts{it}.fibers));
   tract.coords = tracts{it}.fibers(randperm(fiber_count));

   savejson('', tract, fullfile('tracts',sprintf('%i.json',it)));
   all_tracts(it).filename = sprintf('%i.json',it);
   clear tract
end

% Save json outputs
savejson('', all_tracts, fullfile('tracts/tracts.json'));

% Create and write output_fibercounts.txt file
for i = 1 : length(fg_classified)
    name = fg_classified{i}.name;
    num_fibers = length(fg_classified{i}.fibers);

    fibercounts(i) = num_fibers;
    tract_info{i,1} = name;
    tract_info{i,2} = num_fibers;
end

T = cell2table(tract_info);
T.Properties.VariableNames = {'Tracts', 'FiberCount'};

writetable(T, 'output_fibercounts.txt');

exit;
end

