from PIL import Image
import cv2
import cupy as np
from os import chdir, path
from sandbox import predictions, model, layers, activations

# Dataset - https://www.kaggle.com/datasets/dansbecker/hot-dog-not-hot-dog
chdir(path.dirname(path.abspath(__file__)))

for i, image in enumerate(['test\\0.png', 'test\\1.png', 'test\\2.png', 'test\\3.png']):
    img = Image.open(image).convert('L')
    
    # Crop image to 1:1 aspect ratio
    width, height = img.size
    if width > height:
        diff = (width - height) // 2
        img = img.crop((diff, 0, width - diff, height))
    elif height > width:
        diff = (height - width) // 2
        img = img.crop((0, diff, width, height - diff))
    
    # Resize to uniform dimension
    img = img.resize((64, 64))

    img.save(f'{i}.jpg')

model = model.Model(cuda=True)
model.add(layers.Dense(units=5, activation=activations.ReLU()))
model.add(layers.Dense(units=1, activation=activations.Sigmoid()))
model.load(name='parameters.json')

print(model.predict(np.array([cv2.imread('0.jpg', cv2.IMREAD_GRAYSCALE).flatten()]) / 255))
print(model.predict(np.array([cv2.imread('1.jpg', cv2.IMREAD_GRAYSCALE).flatten()]) / 255))
print(model.predict(np.array([cv2.imread('2.jpg', cv2.IMREAD_GRAYSCALE).flatten()]) / 255))
print(model.predict(np.array([cv2.imread('3.jpg', cv2.IMREAD_GRAYSCALE).flatten()]) / 255))
