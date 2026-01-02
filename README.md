# Underwater Image Enhancer and Object Detection

This project provides tools for enhancing underwater images and performing object detection on them. It combines MATLAB-based image processing techniques for enhancement with Python-based YOLOv5/YOLOv8 for object detection.

## Requirements

- **Python 3.11** for training the object detection model
- **MATLAB R2024b** with **Python 3.10** integration for image enhancement scripts

### Dependencies

- Python libraries: Install via `pip install -r requirements.txt` (if available)
- MATLAB Toolboxes: Image Processing Toolbox, Computer Vision Toolbox (if applicable)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/underwater-image-enhancer-object-detection.git
   cd underwater-image-enhancer-object-detection
   ```

2. Set up Python environment:
   - Ensure Python 3.11 is installed for training
   - Install required packages:
     ```bash
     pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118  # or appropriate version
     pip install ultralytics  # for YOLO
     ```

3. Set up MATLAB:
   - Install MATLAB R2024b
   - Ensure Python 3.10 is configured for MATLAB-Python integration
   - Add the project directory to MATLAB path

## Usage

### Image Enhancement (MATLAB)

Run the main enhancement script:
```matlab
run('main_code.m')
```

Available enhancement functions:
- `gammaCorrection.m`
- `gaussian_pyramid.m`
- `gray_balance.m`
- `redCompensate.m`
- `sharp.m`

### Object Detection Training (Python)

Train the model using the provided dataset:
```bash
python train.py
```

The trained model weights are saved as `best.pt`.

### Dataset

The project uses the Aquarium Pretrain Dataset located in `aquarium_pretrain_dataset/`. This dataset contains images and labels for underwater object detection.

- Train/Test split available
- Annotations in YOLO format

## Project Structure

- `train.py`: Python script for training the object detection model
- `*.m`: MATLAB scripts for image enhancement
- `aquarium_pretrain_dataset/`: Dataset folder
- `best.pt`: Trained model weights

## Contributing

Contributions are welcome! Please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.