%% CAS 3116: Homework 3

%% Change the filename to use your own image
image = imread('my_image.jpg');
[x, y, scores, Ih, Iv] = extract_keypoints(image);

%% Part e to produce cardinal_harris.png and my_image_harris.png
% Some of your images may need different circle_size_modifier. Change this
% to other values as needed when testing out your images.
circle_size_modifier = 100000000000;

close all;
imshow(image); hold on;
for i=1:length(scores)
    plot(x(i), y(i), 'g.'); 
    circle_size = abs(scores(i)) / circle_size_modifier;
    % Some scores may be <0, so we take the abs.
    plot(x(i), y(i), 'ro', 'MarkerSize', circle_size); 
end
hold off;

%% Saving the figure
% Change the output filenames to my_image_harris.png as needed

% This saves what is shown on the figure window. Thus, you may want to
% slighly resize the figure window such that the circles have reasonable
% sizes. If you want to resize the figure window then save the figure, 
% simply call the following command AFTER you resize the window.
saveas(gcf, 'my_image_harris.png');