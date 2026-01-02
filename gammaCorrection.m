
function [result] = gammaCorrection(img, alpha, gamma)
img = im2double(img);
result = alpha * (img .^ gamma);
end
