function x=blobAnalysis(im, space)
x = zeros(size(im));

switch space
    case 'rgb'
        im = double(im);
        R = double(im(:,:,1));
        G = double(im(:,:,2));
        B = double(im(:,:,3));
        S = R + G + B + 0.01;
        Z = zeros(size(S));
        Min = min((R-G)./S, (R-B)./S);
        val = max(Z, Min).*10;
        meanR = mean2(R);
        meanG = mean2(G);
        meanB = mean2(B);
        bruteForce = (im(:,:,1) > meanR) & (im(:,:,2) < meanG) & (im(:,:,3) < meanB);
        x1 = (val & bruteForce);
        
    
end
x(:,:,1) = x1;
x(:,:,2) = x(:,:,1);
x(:,:,3) = x(:,:,1);
end


