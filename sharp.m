function [result] = sharp(img)
    % Ensure the input image is in double format
    img = im2double(img);
    
    % Create a Gaussian kernel for blurring (smaller kernel size and lower sigma)
    GaussKernel = fspecial('gaussian', [3, 3], 1); % Reduced kernel size and sigma
    
    % Apply Gaussian blur to the image
    imBlur = imfilter(img, GaussKernel, 'replicate');
    
    % Compute the unsharp mask
    unSharpMask = img - imBlur;
    
    % Enhance the unsharp mask by scaling it (adjust factor as needed)
    enhancementFactor = 2.5; % Increase sharpness (higher value for stronger effect)
    enhancedMask = unSharpMask * enhancementFactor;
    
    % Combine the original image with the enhanced unsharp mask
    result = img + enhancedMask;
    
    % Clip values to ensure they remain within the valid range [0, 1]
    result = max(0, min(result, 1));
end

function [result] = hisStretching(img)
    % Ensure the input image is in double format
    img = im2double(img);
    
    % Apply histogram stretching using rescale (simplifies the process)
    if size(img, 3) == 3
        % For RGB images, stretch each channel separately
        r = rescale(img(:, :, 1));
        g = rescale(img(:, :, 2));
        b = rescale(img(:, :, 3));
        result = cat(3, r, g, b);
    else
        % For grayscale images, stretch directly
        result = rescale(img);
    end
end