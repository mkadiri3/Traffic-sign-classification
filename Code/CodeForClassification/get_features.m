function features = get_features(train_path_pos, feature_params)

image_files = dir( fullfile( train_path_pos, '*.jpg') );
num_images = length(image_files);

size_temp = feature_params.template_size;
features = [];
for i = 1 : num_images
    img = im2single(imread(fullfile(train_path_pos, image_files(i).name)));
    img = imresize(img, [size_temp size_temp]);
    hog = vl_hog(img, feature_params.hog_cell_size, 'variant', 'dalaltriggs');
    [m, n, ~] = size(hog);
    clear hog_temp;
    hog_temp = [];
    for k = 1 : m
        for j = 1: n
            temp = hog(k,j,:);
            temp = temp(:);
            hog_temp = [hog_temp, temp'];
        end        
    end      
    features(end+1, :) = hog_temp;
end
