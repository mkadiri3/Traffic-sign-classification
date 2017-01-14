clc;
clear variables;
close all

readDirectory = '../../Data/VideosForCreatingDatabaseOfImages/1/';
textFileName = 'SignInfo.txt';
VideoFileName = '1.mp4';

writeDirectory = '../../Data/TrainImages/';
if ~exist(writeDirectory, 'dir')
    mkdir(writeDirectory);
end

stop = [writeDirectory,'Stop/'];
NoParking = [writeDirectory 'NoParking/'];
Negative = [writeDirectory 'Negative/'];

if ~exist(stop, 'dir')
    mkdir(stop);
end
if ~exist(NoParking, 'dir')
    mkdir(NoParking);
end
if ~exist(Negative, 'dir')
    mkdir(Negative);
end

[A, SignName] = parse([readDirectory textFileName]);
% Format of A is [frameNumber distance x1 y1 x2 y2 x3 y3 x4 y4 cx cy];
s = 1;
k = 0;
offset = 3;

readerobj = VideoReader([readDirectory VideoFileName]);

tic;
while hasFrame(readerobj)
    image = readFrame(readerobj);
    k = k+1;
    
    % Generating num_negative_images_per_frame negative images randomly from each frame
    num_negative_images_per_frame = 5;
    xycoordinates_for_random_negative_images = randi([1 min(size(image,1)/2, size(image,2)/2)], ...
                                                        2, num_negative_images_per_frame);
    
    % Set width of the image
    width1 =[40,40];
    width1 = repmat(width1, num_negative_images_per_frame,1);
    rect1 = [xycoordinates_for_random_negative_images' width1];    
    
    for i=1:size(rect1,1)
        image2 = imcrop(image,rect1(i,:));
        imwrite(image2,[Negative,num2str(s),'.jpg']);
    end
    
    while(A(s,1) == (k-1))
        width = [];
        height = [];
        x11 = [];
        y11 = [];
        threshold = 3000;
        if(A(s,2) < threshold)
            width(end+1,1) = A(s,9) - A(s,3);
            height(end+1,1) = A(s,10) - A(s,4);
            x11(end+1,1) = A(s,3) + offset;
            y11(end+1,1) = A(s,4);
            rect = [x11 y11 width height];
            for i=1:size(rect,1)                
                image1 = imcrop(image,rect(i,:));
                if(strcmp(SignName{s},'SP'))
                    imwrite(image1,[stop, num2str(s), '.jpg']);
                else if(strcmp(SignName{s},'NP'))                        
                        imwrite(image1,[NoParking, num2str(s), '.jpg']);
                    end
                end
            end
        end
        s = s+1;
    end
end
toc