clear all
clc

%load original image and display
image = imread('FP_Image10.png');
figure
imshow(image);
title('Original Image');

%get the gradient of the magnitude of image and display
grayscale_image = im2double(rgb2gray(image));
blurred_image = imgaussfilt(grayscale_image,3);
[Gmag, Gdir] = imgradient(blurred_image, 'prewitt');
thresholded_image = im2bw(Gmag, 0.1);
figure
imshow(Gmag);
colormap gray
figure
imshow(thresholded_image);
colormap gray
convex_hull_image = bwconvhull(thresholded_image, 'objects');
figure
imshow(convex_hull_image);
colormap gray
Edges = edge(convex_hull_image, 'approxcanny');
figure
imshow(Edges);
colormap gray

%corner-detection algorithm (Harris Stephens algorithm)
points = detectHarrisFeatures(convex_hull_image);
imagesc(Edges);
title('Corners on Image');
hold on;

%select the strongest points from the identified corners
strongest_points= points.selectStrongest(20);
plot(strongest_points);

%define layout of new image
newI = zeros(size(Edges));
fixedPoints = [1, size(image, 1); 1, 1; size(image, 2), size(image, 1); size(image, 2), 1];

%identify the location of the corners
case1 = 0;
case2 = 0;
case3 = 0;
case4 = 0;
for i = 1:20
  if (strongest_points.Location(i, 1) < (size(image, 2) / 2)) && (strongest_points.Location(i, 2) > (size(image, 1) / 2))
    if case1 == 0
      BL1 = strongest_points.Location(i, 1);
      BL2 = strongest_points.Location(i, 2);
    elseif (i > 1) && (strongest_points.Location(i, 1) < BL1) && (strongest_points.Location(i, 2) > BL2)
      BL1 = strongest_points.Location(i, 1);
      BL2 = strongest_points.Location(i, 2);
    end
    case1 = 1;
  elseif (strongest_points.Location(i, 1) < (size(image, 2) / 2)) && (strongest_points.Location(i, 2) < (size(image, 1) / 2))
    if case2 == 0
      TL1 = strongest_points.Location(i, 1);
      TL2 = strongest_points.Location(i, 2);
    elseif (i > 1) && (strongest_points.Location(i, 1) < TL1) && (strongest_points.Location(i, 2) < TL2)
      TL1 = strongest_points.Location(i, 1);
      TL2 = strongest_points.Location(i, 2);
    end
    case2 = 1;
  elseif (strongest_points.Location(i, 1) > (size(image, 2) / 2)) && (strongest_points.Location(i, 2) > (size(image, 1) / 2))
    if case3 == 0
      BR1 = strongest_points.Location(i, 1);
      BR2 = strongest_points.Location(i, 2);
    elseif (i > 1) && (strongest_points.Location(i, 1) > BR1) && (strongest_points.Location(i, 2) > BR2)
      BR1 = strongest_points.Location(i, 1);
      BR2 = strongest_points.Location(i, 2);
    end
    case3 = 1;
  elseif (strongest_points.Location(i, 1) > (size(image, 2) / 2)) && (strongest_points.Location(i, 2) < (size(image, 1) / 2))
    if case4 == 0
      TR1 = strongest_points.Location(i, 1);
      TR2 = strongest_points.Location(i, 2);
    elseif (i > 1) && (strongest_points.Location(i, 1) > TR1) && (strongest_points.Location(i, 2) < TR2)
      TR1 = strongest_points.Location(i, 1);
      TR2 = strongest_points.Location(i, 2);
    end
    case4 = 1;
  end
end

%define new image and display
movingPoints = [BL1, BL2; TL1, TL2; BR1, BR2; TR1, TR2];
tform = fitgeotrans(movingPoints, fixedPoints, 'projective');
newI = imwarp(image, tform, 'OutputView', imref2d(size(newI)));
figure
imshow(newI);
title('Scanned Image');

%filter new image using unsharp masking & display
filtI = imsharpen(newI, 'Radius', 2, 'Amount', 1);
figure
imshow(filtI);
title('Filtered Image');
