function out = redCompensate(img, alpha)
% RED CHANNEL COMPENSATION ONLY (PIPELINE SAFE)
% alpha: 1.0 – 2.5 recommended

if nargin < 2
    alpha = 1.0;
end

img = im2double(img);

R = img(:,:,1);
G = img(:,:,2);
B = img(:,:,3);

% Global means
meanR = mean(R(:));
meanG = mean(G(:));

% Red compensation (green-guided)
R_comp = R + alpha * (meanG - meanR) .* G;

% Clip to valid range
R_comp = min(max(R_comp, 0), 1);

% Rebuild image (ONLY red modified)
out = img;
out(:,:,1) = R_comp;
out(:,:,2) = G;
out(:,:,3) = B;

end
