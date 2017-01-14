close all
clear variables
clc

% Have to run this for vl functions to work.
run('../../vlfeat-0.9.20-bin/vlfeat-0.9.20-bin/vlfeat-0.9.20/toolbox/vl_setup')

% Just a naming format for the outputs
formatOut = 'dd_mm_yy_HH_MM_ss';
timeString = datestr(now,formatOut);

%Training Image Database folder
train_data_path = '../../Data/TrainImages/';

%TestVideo directory
test_video_directory = '../../Data/TestVideo/';

% Test Video Name
VideoName = '8';

% Change the extension here
% Beware! The saved video will have the same extension
extension = '.mp4';

%Saved Video Directory
VideoWriterDirectory = ('../../Results/');

if ~exist(VideoWriterDirectory, 'dir')
    mkdir(VideoWriterDirectory);
end

VideoFileName = cat(2,VideoName, extension);
VideoWriterFileName = [VideoName '_' timeString extension];

train_path_np = fullfile(train_data_path, 'NoParking');
train_path_stop = fullfile(train_data_path, 'Stop');
train_path_negative = fullfile(train_data_path, 'Negative');

% Feature pararmeters for HoG
feature_params = struct('template_size', 36, 'hog_cell_size', 6);


%% Step 1. Load positive training crops and random negative examples

if ~exist('features_np.mat', 'file')
    fprintf('No existing NoParking features found. Computing one from training images\n')
    features_np = get_features( train_path_np, feature_params );
    save('features_np.mat', 'features_np')
else
    fprintf('features_np found\n')
    load('features_np.mat')
end

if ~exist('features_stop.mat', 'file')
    fprintf('No existing features_stop found. Computing one from training images\n')
    features_stop = get_features( train_path_stop, feature_params );
    save('features_stop.mat', 'features_stop')
else
    fprintf('features_stop found\n')
    load('features_stop.mat')
end

if ~exist('features_neg.mat', 'file')
    fprintf('No existing features_neg found. Computing one from training images\n')
    features_neg = get_features( train_path_negative, feature_params);
    save('features_neg.mat', 'features_neg')
else
    fprintf('features_neg found\n')
    load('features_neg.mat')
end

%% step 2. Train Classifier
%YOU CODE classifier training. Make sure the outputs are 'w' and 'b'.
numNPFeatures = size(features_np,1);
numStopFeatures = size(features_stop,1);
numNegFeatures = size(features_neg,1);
lambda = 0.00001;

% For No-Parking
tic
y1 = ones(numNPFeatures,1);
y2 = -1*ones(numNegFeatures,1);
Y = [y1;y2];
X = [features_np', features_neg'];
[w, b] = vl_svmtrain(X, Y, lambda);
toc

% For stop
tic
y11 = ones(numStopFeatures,1);
y21 = -1*ones(numNegFeatures,1);
Y1 = [y11;y21];
X1 = [features_stop', features_neg'];
[w1, b1] = vl_svmtrain(X1, Y1, lambda);
toc

%% Step 5. Run detector on test set.
readerobj = VideoReader([test_video_directory VideoFileName]);
videoWriterObj = VideoWriter([VideoWriterDirectory VideoWriterFileName]);
space = 'rgb';
thresh = 0.67;
open(videoWriterObj);

tic
while hasFrame(readerobj)
    image = readFrame(readerobj);
    image1 = image;
    out = blobAnalysis(image, space);
%     figure(1);
%      imshow(out);
%      pause;
%    
    % Restricting the circle radius between 10 and 100
    [center_old, radius_old] = imfindcircles(out, [10 100], 'Sensitivity', 0.93, 'Method', 'twostage');
    [center, radius] = mergeOverlappingCircles(center_old, radius_old);
    
    if(~isempty(center))
        offset = 3;
        
        % Running for all segments found by blob anaysis and imfindcircles
        for z = 1 : size(center, 1)
            x = center(z, 1)-offset;
            y = center(z, 2)-offset;
            width = radius(z)+(2*offset);
            
            % Draawing the bounding box for radius greater than 20
            if(width > 20 && width < 150)
                if((x-width > 0) && (y-width > 0) && (x+width < size(image, 2)) && (y+width < size(image, 1)))
                    rect =  [x-width y-width width*2 width*2];
%                     out = insertShape(out,'Rectangle',rect, 'Color', 'red');
%                     figure(1);
%                     imshow(out);
%                     pause;
%      
%      
                    test_image_segments = imcrop(image, rect);
                    [bboxes, confidences, label] = run_detector(test_image_segments, w, b, feature_params, 'NoParking');
                    [bboxes1, confidences1, label1] = run_detector(test_image_segments, w1, b1, feature_params, 'Stop');
                    
                    if(isempty(confidences1) & confidences > thresh)
                        image1 = visualise(rect, confidences, image, label);
                    elseif(isempty(confidences) & confidences1 > thresh)
                        image1 = visualise(rect, confidences1, image, label1);
                    elseif (confidences1 <= confidences & confidences > thresh)
                        image1 = visualise(rect, confidences, image, label);
                    elseif(confidences1 > confidences & confidences1 > thresh)
                        image1 = visualise(rect, confidences1, image, label1);
                    end
                end
            end
        end
    end
    
    writeVideo(videoWriterObj,  image1);
end
toc
close(videoWriterObj);