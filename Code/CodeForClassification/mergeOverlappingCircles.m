function [centers, radius] = mergeOverlappingCircles(centers, radius)
% Merges overlapping circles and smaller circles within bigger circles
% Checks for distance between the centers and compares it with the sum of
% the radius
m = 100;
centers = round(centers);
radius = round(radius);
for i = 1 : m
    if(i >= size(centers,1))
        break;
    end
    for j = i+1 : m
        if(j >= size(centers,1))
            break;
        end
        center_diff = centers(j,:) - centers(i,:);
        norm_val = norm(center_diff);
        radius_sum = (radius(i) + radius(j));
        if( norm_val <= radius_sum)
            centers(i,:) = round((centers(i,:) + centers(j,:)) / 2);
            radius(i) = radius_sum;
            centers(j,:) = [];
            radius(j,:) = [];
            j = j-1;
        end
    end
end
centers = round(centers);
radius = round(radius);
end