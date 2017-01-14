function [A, SignName] = parse(fileName)
fileID = fopen(fileName, 'r');
out = textscan(fileID, '%d %d %s %f %f %f %f %f %f %f %f %f %f %f', 'HeaderLines',1);

[frameNumber, ~, SignName, cx, cy, x1, y1, x2, y2, x3, y3, x4, y4, distance] = out{1:end};
A = [frameNumber distance x1 y1 x2 y2 x3 y3 x4 y4 cx cy];
end
