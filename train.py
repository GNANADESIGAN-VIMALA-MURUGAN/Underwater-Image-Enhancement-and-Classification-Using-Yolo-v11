import torch
from ultralytics import YOLO
import logging

logging.basicConfig(level=logging.INFO)

def main():
    # Check if CUDA is available
    device = 'cuda' if torch.cuda.is_available() else 'cpu'
    print(f"Using device: {device}")

    try:
        # Load a pre-trained YOLOv11 model (e.g., yolo11n.pt for nano, or yolo11s.pt for small)
        # You can change to 'yolo11m.pt', 'yolo11l.pt', or 'yolo11x.pt' for larger models
        print("Attempting to load YOLOv11 model...")
        model = YOLO('yolo11n.pt')  # Nano model for efficiency
        print("Model loaded successfully.")
    except Exception as e:
        print(f"Error loading model: {e}")
        logging.error(f"Model loading failed: {e}")
        return

    # Path to data.yaml
    data_path = 'aquarium_pretrain_dataset/data.yaml'

    # Training parameters
    epochs = 100  # Increased epochs for better accuracy
    batch_size = 4  # Reduced batch size to save memory
    imgsz = 640  # Image size

    # Train the model
    results = model.train(
        data=data_path,
        epochs=epochs,
        batch=batch_size,
        imgsz=imgsz,
        device=device,
        project='runs/train',  # Directory to save results
        name='aquarium_yolov11',  # Experiment name
        save=True,  # Save checkpoints
        save_period=10,  # Save every 10 epochs
        cache=False,  # Cache images in RAM (set to True if enough RAM)
        workers=4,  # Number of workers for data loading
        patience=10,  # Early stopping patience
        optimizer='Adam',  # Optimizer
        lr0=0.001,  # Initial learning rate
        weight_decay=0.0005,  # Weight decay
        augment=True,  # Enable data augmentation
    )

    # Save the best model
    model.save('best.pt')

    print("Training completed. Best model saved as 'best.pt'")

if __name__ == "__main__":
    main()