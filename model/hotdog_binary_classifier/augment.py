from PIL import Image, ImageOps
import os
import shutil

# Dataset - https://www.kaggle.com/datasets/dansbecker/hot-dog-not-hot-dog
dataset_path = 'C:\\Users\\kayde\\OneDrive\\Documents\\AI\\neural-network\\neural-network\\examples\\hotdog_binary_classifier\\dataset\\'
os.chdir(dataset_path)

# Clear altered dataset, remake folders
try:
    shutil.rmtree('altered\\')
    os.mkdir('altered\\')
except:
    os.mkdir('altered\\')

os.mkdir('altered\\train\\')
os.mkdir('altered\\test\\')

for dir in ['\\train\\hotdog\\', '\\train\\nothotdog\\', '\\test\\hotdog\\', '\\test\\nothotdog\\']:
    os.mkdir(f'altered{dir}')
    for i, image in enumerate(os.listdir(f'original{dir}')):
        img = Image.open(f'original{dir}{image}')
        
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
        
        # Create rotated copies of the image
        # for j in range(4):
        #     img = img.rotate(90)
        #     img.save(f'altered{dir}{i}{j}.jpg')

        img.save(f'altered{dir}{i}.jpg')
