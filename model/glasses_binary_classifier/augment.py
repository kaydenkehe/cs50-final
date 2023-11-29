from PIL import Image
from os import chdir, mkdir, path, listdir
from shutil import rmtree

# Dataset - https://www.kaggle.com/datasets/dansbecker/hot-dog-not-hot-dog
chdir(path.dirname(path.abspath(__file__)))
chdir('dataset\\')

# Clear altered dataset, remake folders
try:
    rmtree('altered\\')
    mkdir('altered\\')
except:
    mkdir('altered\\')

mkdir('altered\\train\\')
mkdir('altered\\test\\')

for dir in ['\\train\\pizza\\', '\\train\\not_pizza\\', '\\test\\pizza\\', '\\test\\not_pizza\\']:
    mkdir(f'altered{dir}')
    for i, image in enumerate(listdir(f'original{dir}')):
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
        for j in range(4):
            img = img.rotate(90)
            img.save(f'altered{dir}{i}{j}.jpg')

        # img.save(f'altered{dir}{i}.jpg')
