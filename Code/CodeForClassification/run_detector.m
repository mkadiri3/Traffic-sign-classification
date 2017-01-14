function [bboxes, confidences, label] = run_detector(image, w, b, feature_params, label)
bboxes = [];
confidences = [];
threshold = -2;
step_size = 2;

template_size = feature_params.template_size;
hog_cell_size = feature_params.hog_cell_size;

cur_bboxes = [];
cur_confidences = [];


for i = 1:1
    count = 1;
    img = image;
    img = single(img)/255;
    if(size(img,3) > 1)
        img = rgb2gray(img);
    end
    
    scale = [0.5 0.6 0.75 0.85 1];
    
    for j = 1: length(scale);
        img_temp = imresize(img, scale(j));
        [width, height] = size(img_temp);
        width_rescale = 1;
        height_rescale = 1;
            
        if(size(img_temp, 1) < template_size)
            width_rescale = width/template_size;
            img_temp = imresize(img, [template_size size(img_temp, 2)]);
        end
        
        if( size(img_temp, 2) < template_size)
            height_rescale = height/template_size;
            img_temp = imresize(img, [size(img_temp, 1) template_size]);
        end
        
        end1 = size(img_temp, 1)-template_size-1;
        end2 = size(img_temp, 2)-template_size-1;
        
        
        for q = 1 : step_size : end1
            for e = 1 : step_size : end2
                img_hog = img_temp(q:q+template_size-1, e:e+template_size-1);
                hog = vl_hog(img_hog, hog_cell_size, 'variant', 'dalaltriggs');
                clear m1; clear n1, clear p1;
                [m1, n1, ~] = size(hog);
                clear hog_temp;
                hog_temp = [];
                for q1 = 1 : m1
                    for w1 = 1: n1
                        temp = hog(q1, w1,:);
                        temp = temp(:)';
                        hog_temp = [hog_temp, temp];
                    end
                end
                
                confidence_temp = w'*hog_temp' + b;
                if(confidence_temp > threshold)
                    curr_x_min = round(e /  (scale(j) * height_rescale));
                    curr_x_max = round((e + template_size)/ (scale(j) * height_rescale));
                    curr_y_min = round(q /  (scale(j) * width_rescale));
                    curr_y_max = round((q + template_size)/ (scale(j) * width_rescale));
                    
                   if(curr_x_min > size(img, 2))
                        curr_x_min = size(img, 2);
                    end
                    if(curr_x_max > size(img, 2))
                        curr_x_max = size(img, 2);
                    end
                    if(curr_y_min > size(img, 1))
                        curr_y_min = size(img, 1);
                    end
                    if(curr_y_max > size(img, 1))
                        curr_y_max = size(img, 1);
                    end
                    cur_bboxes(count, :) = [curr_x_min, curr_y_min, curr_x_max, curr_y_max];
                    cur_confidences(count, 1) = confidence_temp;
                    count = count+1;
                end
            end
        end
    end
    
    if(~isempty(cur_bboxes))
        is_maximum = non_max_supr_bbox(cur_bboxes, cur_confidences, size(img));
        
        cur_confidences = cur_confidences(is_maximum,:);
        cur_bboxes = cur_bboxes(is_maximum,:);
        
        bboxes = [bboxes; cur_bboxes];
        confidences = [confidences; cur_confidences];
    end
    
    [val, I] = max((confidences));
    bboxes = bboxes(I, :);
    confidences = val;
end




