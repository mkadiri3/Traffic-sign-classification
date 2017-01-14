%This function visualizes all detections in each test image
function image = visualise(bboxes, confidences, image, label)

if(strcmp(label, 'Stop'))
    image = insertShape(image,'Rectangle',bboxes, 'Color', 'blue');
    image = insertText(image,[bboxes(1) bboxes(2)], label, 'BoxOpacity', 0, ...
        'AnchorPoint', 'RightBottom', 'TextColor', 'blue', 'FontSize', 15);
else
    image = insertShape(image,'Rectangle',bboxes, 'Color', 'blue');
    image = insertText(image,[bboxes(1) bboxes(2)], label, 'BoxOpacity', 0, ...
        'AnchorPoint', 'RightBottom', 'TextColor', 'blue','FontSize', 15);
end
end



