function main_app()
    clc; clear; close all;

    % ===== 1. Global Counter Persistence =====
    counterFile = 'global_counter.mat';
    if exist(counterFile, 'file')
        S = load(counterFile);
        globalCounter = S.globalCounter;
    else
        globalCounter = 0;
    end

    % ===== 2. Select Image Initially =====
    [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', ...
        'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, 'Select an Image File');
    
    if isequal(file, 0) || isequal(path, 0)
        disp('User canceled the image selection. Exiting...');
        return;
    end

    imagePath = fullfile(path, file);
    org_img = imread(imagePath);

    % ===== 3. Initialize Data Structure =====
    data.modelPath = 'best.pt';  % Ensure this file exists
    data.org_img = org_img;
    
    % Initialize processing placeholders
    data.red_comp_img = [];
    data.wb_img = [];
    data.gamma_crct_img = [];
    data.sharpen_img = [];
    data.gray_img = [];
    data.edges = [];
    data.dilated_img = [];
    data.filled_img = [];
    
    % State variables
    data.outputPath = '';     % Tracks if YOLO has saved a file
    data.globalCounter = globalCounter;
    data.counterFile = counterFile;
    data.stepCounter = 1;     
    data.isProcessing = false; % Flag to prevent double clicks

    % ===== 4. Create GUI =====
    fig = figure('Name', 'Image Processing Pipeline', 'NumberTitle', 'off', ...
        'Position', [100, 100, 1150, 700], 'MenuBar', 'none', 'ToolBar', 'none');

    % Main image axes
    data.ax = axes('Parent', fig, 'Units', 'pixels', 'Position', [270, 150, 860, 500]);
    axis(data.ax, 'off');
    
    % Thumbnail panel
    data.thumbPanel = uipanel('Parent', fig, 'Title', 'Steps', 'FontSize', 10, ...
        'Position', [0.005, 0.02, 0.23, 0.94]);
    data.thumbAxes = {};

    % Buttons
    uicontrol('Style', 'pushbutton', 'String', 'Select Image', 'FontSize', 12, ...
        'Position', [480, 40, 120, 40], 'Callback', @(~,~) selectImage(fig));
        
    data.nextButton = uicontrol('Style', 'pushbutton', 'String', 'Next', 'FontSize', 12, ...
        'Position', [800, 40, 100, 40], 'Callback', @(~,~) nextStep(fig), 'Enable', 'on');
        
    data.backButton = uicontrol('Style', 'pushbutton', 'String', 'Back', 'FontSize', 12, ...
        'Position', [650, 40, 100, 40], 'Callback', @(~,~) backStep(fig), 'Enable', 'off');

    % Show first image
    imshow(org_img, 'Parent', data.ax);
    title(data.ax, 'Input Image');
    data = storeThumbnail(fig, data, org_img, 'Input Image');

    guidata(fig, data);
end

%% ======== SELECT IMAGE Function ========
function selectImage(fig)
    data = guidata(fig);
    [file, path] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', ...
        'Image Files (*.jpg, *.jpeg, *.png, *.bmp)'}, 'Select an Image File');
        
    if isequal(file, 0) || isequal(path, 0)
        return;
    end
    
    % --- RESET ALL DATA FOR NEW IMAGE ---
    data.org_img = imread(fullfile(path, file));
    
    % Clear all intermediate steps
    data.red_comp_img = [];
    data.wb_img = [];
    data.gamma_crct_img = [];
    data.sharpen_img = [];
    data.gray_img = [];
    data.edges = [];
    data.dilated_img = [];
    data.filled_img = [];
    data.outputPath = ''; 
    
    % Clear UI
    cla(data.ax);
    for i = 1:length(data.thumbAxes)
        delete(data.thumbAxes{i});
    end
    data.thumbAxes = {};
    
    % Reset Controls
    data.stepCounter = 1;
    data.isProcessing = false;
    
    imshow(data.org_img, 'Parent', data.ax);
    title(data.ax, 'Input Image');
    
    % Store first thumbnail
    data = storeThumbnail(fig, data, data.org_img, 'Input Image');
    
    set(data.nextButton, 'Enable', 'on');
    set(data.backButton, 'Enable', 'off');
    
    guidata(fig, data);
end

%% ======== NEXT Button Function ========
function nextStep(fig)
    data = guidata(fig);
    
    % --- 1. PREVENT DOUBLE CLICKING ---
    if data.isProcessing
        return; % Ignore click if already working
    end
    data.isProcessing = true;
    set(data.nextButton, 'Enable', 'off');
    set(data.backButton, 'Enable', 'off');
    guidata(fig, data); 
    drawnow; % Force UI update immediately
    
    try
        switch data.stepCounter
            case 1  % Red Compensation
                if isempty(data.red_comp_img)
                    data.red_comp_img = redCompensate(data.org_img, 5); 
                    data = storeThumbnail(fig, data, data.red_comp_img, 'Red Compensated Image');
                end
                imgToShow = data.red_comp_img;
                titleText = 'Red Compensated Image';
                
            case 2  % White Balance
                if isempty(data.wb_img)
                    data.wb_img = gray_balance(data.red_comp_img); 
                    data = storeThumbnail(fig, data, data.wb_img, 'White Balanced Image');
                end
                imgToShow = data.wb_img;
                titleText = 'White Balanced Image';
                
            case 3  % Gamma Correction
                if isempty(data.gamma_crct_img)
                    alpha = 1; gamma = 1.2;
                    data.gamma_crct_img = gammaCorrection(data.wb_img, alpha, gamma);
                    data = storeThumbnail(fig, data, data.gamma_crct_img, 'Enhanced Image');
                end
                imgToShow = data.gamma_crct_img;
                titleText = 'Enhanced Image';
                
            case 4  % Sharpening
                if isempty(data.sharpen_img)
                    data.sharpen_img = sharp(data.gamma_crct_img);
                    data = storeThumbnail(fig, data, data.sharpen_img, 'Sharpened Image');
                end
                imgToShow = data.sharpen_img;
                titleText = 'Sharpened Image';
                
            case 5  % Grayscale
                if isempty(data.gray_img)
                    data.gray_img = rgb2gray(data.sharpen_img);
                    data = storeThumbnail(fig, data, data.gray_img, 'Grayscale Image');
                end
                imgToShow = data.gray_img;
                titleText = 'Grayscale Image';
                
            case 6  % Edge Detection
                if isempty(data.edges)
                    data.edges = edge(data.gray_img, 'Canny');
                    data = storeThumbnail(fig, data, data.edges, 'Edge Detection');
                end
                imgToShow = data.edges;
                titleText = 'Edge Detection';
                
            case 7  % Morphology
                if isempty(data.filled_img)
                    se = strel('disk', 3);
                    data.dilated_img = imdilate(data.edges, se);
                    data.filled_img = imfill(data.dilated_img, 'holes');
                    data = storeThumbnail(fig, data, data.filled_img, 'Morphologically Processed');
                end
                imgToShow = data.filled_img;
                titleText = 'Morphologically Processed Image';

            case 8  % YOLOv8 Detection
                
                % Check if we already have output (PREVENT RE-RUN)
                if ~isempty(data.outputPath) && exist(data.outputPath, 'file')
                    imgToShow = imread(data.outputPath);
                    if contains(data.outputPath, 'no_detection')
                        titleText = 'No object detected';
                    else
                        titleText = 'Detected Object (Saved)';
                    end
                else
                    % --- RUN YOLO ---
                    outputDir = fullfile(pwd, 'output');
                    if ~exist(outputDir, 'dir'), mkdir(outputDir); end
                    
                    t = clock;
                    dateStr = sprintf('%02d-%02d-%04d', t(3), t(2), t(1));
                    tempImagePath = fullfile(outputDir, 'temp_input.jpg');
                    imwrite(data.gamma_crct_img, tempImagePath);
                    
                    try
                        ultra = py.importlib.import_module('ultralytics');
                        model = ultra.YOLO(data.modelPath);
                        results = model(tempImagePath);
                        boxes = results{1}.boxes;
                        
                        % Prepare global counter
                        data.globalCounter = data.globalCounter + 1;
                        
                        if boxes.cls.numel() == 0
                            % No detections
                            outputFileName = sprintf('%d_no_detection_%s.jpg', data.globalCounter, dateStr);
                            outputPath = fullfile(outputDir, outputFileName);
                            imwrite(data.gamma_crct_img, outputPath);
                            imgToShow = data.gamma_crct_img;
                            titleText = 'No object detected';
                        else
                            % Detections found
                            clsList = boxes.cls.tolist();
                            clsList = cellfun(@double, cell(clsList));
                            pyNames = results{1}.names;
                            
                            % Generate Summary String for Filename
                            uniqueCls = unique(clsList);
                            summaryText = "";
                            filenameTags = "";
                            
                            for i = 1:numel(uniqueCls)
                                clsIdx = uniqueCls(i);
                                count = sum(clsList == clsIdx);
                                className = lower(string(pyNames.get(py.int(clsIdx))));
                                summaryText = summaryText + sprintf('%d %s, ', count, className);
                                filenameTags = filenameTags + sprintf('%s_', className);
                            end
                            
                            % --- FIX: SAVE ONLY ONE IMAGE ---
                            outputFileName = sprintf('%d_detected_%s%s.jpg', ...
                                data.globalCounter, filenameTags, dateStr);
                            outputPath = fullfile(outputDir, outputFileName);
                            
                            % Save the single image with all boxes
                            results{1}.save(outputPath);
                            disp(['Saved: ', outputPath]);
                            
                            imgToShow = imread(outputPath);
                            titleText = ['Detected: ', extractBefore(summaryText, strlength(summaryText))];
                        end
                        
                        % Save Global Counter (Use Local Variable)
                        globalCounter = data.globalCounter;
                        save(data.counterFile, 'globalCounter');
                        
                        data.outputPath = outputPath;
                        data = storeThumbnail(fig, data, imgToShow, titleText);
                        
                    catch ME
                        if exist(tempImagePath, 'file'), delete(tempImagePath); end
                        rethrow(ME);
                    end
                    if exist(tempImagePath, 'file'), delete(tempImagePath); end
                end

                % Display Final Result
                imshow(imgToShow, 'Parent', data.ax);
                title(data.ax, titleText);
                
                % Keep buttons disabled as it's the end
                data.isProcessing = false;
                guidata(fig, data);
                return; 
                
            otherwise
                return;
        end
        
        % --- UPDATE GUI FOR INTERMEDIATE STEPS ---
        imshow(imgToShow, 'Parent', data.ax);
        title(data.ax, titleText);
        
        data.stepCounter = data.stepCounter + 1;
        
        % --- UNLOCK BUTTONS ---
        data.isProcessing = false;
        set(data.nextButton, 'Enable', 'on');
        set(data.backButton, 'Enable', 'on');
        guidata(fig, data);
        
    catch ME
        % Error Handling: Unlock buttons so app doesn't freeze
        data.isProcessing = false;
        set(data.nextButton, 'Enable', 'on');
        if data.stepCounter > 1
             set(data.backButton, 'Enable', 'on');
        end
        guidata(fig, data);
        errordlg(ME.message, 'Processing Error');
    end
end

%% ======== BACK Button Function ========
function backStep(fig)
    data = guidata(fig);
    if data.stepCounter <= 1, return; end
    
    data.stepCounter = data.stepCounter - 1;
    
    switch data.stepCounter
        case 1
            imgToShow = data.org_img;
            titleText = 'Input Image';
        case 2
            imgToShow = data.red_comp_img;
            titleText = 'Red Compensated Image';
        case 3
            imgToShow = data.wb_img;
            titleText = 'White Balanced Image';
        case 4
            imgToShow = data.gamma_crct_img;
            titleText = 'Enhanced Image';
        case 5
            imgToShow = data.sharpen_img;
            titleText = 'Sharpened Image';
        case 6
            imgToShow = data.gray_img;
            titleText = 'Grayscale Image';
        case 7
            imgToShow = data.edges;
            titleText = 'Edge Detection';
        case 8
            imgToShow = data.filled_img;
            titleText = 'Morphologically Processed Image';
    end
    
    imshow(imgToShow, 'Parent', data.ax);
    title(data.ax, titleText);
    
    if data.stepCounter == 1
        set(data.backButton, 'Enable', 'off');
    end
    set(data.nextButton, 'Enable', 'on');
    
    guidata(fig, data);
end

%% ======== Store Thumbnail ========
function data = storeThumbnail(fig, data, img, stepTitle)
    thumbSize = [100, 100];
    thumbImg = imresize(img, thumbSize);
    
    idx = numel(data.thumbAxes) + 1;
    col = mod(idx-1, 2);
    row = floor((idx-1)/2);
    
    xPos = 10 + col * 110;
    yPos = 520 - row * 120;
    
    ax = axes('Parent', data.thumbPanel, 'Units', 'pixels', ...
        'Position', [xPos, yPos, 100, 100], 'XTick', [], 'YTick', []);
        
    hImg = imshow(thumbImg, 'Parent', ax);
    title(ax, num2str(idx), 'FontSize', 8);
    
    set(hImg, 'ButtonDownFcn', @(~,~) showImage(fig, img, stepTitle));
    set(ax, 'ButtonDownFcn', @(~,~) showImage(fig, img, stepTitle));
    
    data.thumbAxes{end+1} = ax;
end

%% ======== Show Full Image from Thumbnail ========
function showImage(fig, img, stepTitle)
    data = guidata(fig);
    imshow(img, 'Parent', data.ax);
    title(data.ax, stepTitle);
end