function [Totalpcs Location max_storeColorValue max_label_index] = colormarking(RGB)

% Totalpcs = no. of detected pieces
% Location = pixel location of all pieces, stored in cell
% storeColorValue = represent the color value of the piece having maximum
% area
% maxlabelSize = represent index value of the piece having maximum area

I = (RGB);
threshold = graythresh(I);
bw = im2bw(I,threshold);
figure; imshow(bw); title('Black & White of RGB')

% remove all object containing fewer than 30 pixels
bw = bwareaopen(bw,30);
figure; imshow(bw); title('bwareaopen')

% fill a gap in the pen's cap
se = strel('square',1);
bw = imclose(bw,se);

% fill any holes, so that regionprops can be used to estimate
bw = imfill(bw,'holes');
figure; imshow(bw); title('imfill')

% Find connected objects and color them
[Label,Totalpcs] = bwlabel(bw,8);
stats = regionprops(bw,'Area');

setColorValue = 20;
for i = 1:Totalpcs
    [r c] = find(Label == i);
    rc = [r c];
    LocationStore{i} = rc;
    labelSize(i) = size(rc,1);
        for j = 1:size(r)
            I(r(j),c(j)) = setColorValue;
        end
        storeColorValue(i) = setColorValue;
        setColorValue = setColorValue + 30;
end 
figure; imshow(I); title('labelled image')   

% Find the region corresponding to maximum area. Only to be sure
max_label_index = find(labelSize == max(labelSize));      % Find the label no corresponding to maximum area
max_storeColorValue = storeColorValue(max_label_index);   % Find the setColorValue corresponding to maximum area

Ir = size(I,1); Ic = size(I,2);
Im = zeros(Ir,Ic);
for i = 1:Ir
    for j = 1:Ic
        if I(i,j) == max_storeColorValue
            Im(i,j) = 255;
        else
            Im(i,j) = 0;
        end
    end
end 
figure; imshow(Im); title('max area')
Location = LocationStore;
end 