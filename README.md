# Machine Learning-Based SOC and SOH Prediction for Solid-State Batteries

This repository contains the Simulink models, datasets, and Python machine learning code for the paper: *"Machine Learning-Based State-of-Charge and State-of-Health Prediction for Solid-State Batteries Using a Reduced-Order Physics Model."*

## Contents
* `/Simulink`: The MATLAB/Simulink physics model based on Deng et al. (2020).
* `/Datasets`: The generated SOC and SOH CSV datasets.
* `/Python_Training`: The Google Colab Python scripts used to train the Transformer, LSTM, GRU, and CNN-LSTM models.
* `/TFLite_Deployment`: The compiled `.tflite` models and `scaler.pkl` files, along with an `inference_demo.py` script.

## How to Reproduce
1. Load the Simulink model and run the MATLAB export scripts to generate the CSV files.
2. Upload the CSV files to Google Colab and run the Python training scripts.
3. Load the `.tflite` file and scalers into any Python environment (or microcontroller) for inference.

## Citation
If you use this code or data, please cite our paper:
[Insert Paper Citation Here]
