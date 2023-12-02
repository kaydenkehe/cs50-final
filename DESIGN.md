# Pizza Classifier - Design

This repository contains the source code for a pizza image classification mobile app. It can be split into three major subsections: the frontend, the backend/server, and the deep learning model. 

## Frontend

The frontend is built using Flutter/Dart and can be found in the `frontend/pizza` directory. Here, the only altered file is `main.dart`, with the rest of the files being standard files that are automatically populated upon the creation of a new Flutter project. 

**main.dart**

DESCRIBE MAIN.DART

## Server

The backend of the project is a server built using the Python and Flask and can be found in the `backend` directory. Here, we see three files:

- `parameters.json` - Contains the parameters generated as a result of training the neural network to detect pizza. These parameters are loaded into the model in `app.py`.
- `users.db` - Database containing the usernames and (hashed) passwords for all registered users.
- `app.py` - Python / Flask server that handles user registration, user login, and pizza prediction.

Nothing here is really interesting from a design standpoint. 

## Model

The deep learning model used for the project is built using Python with NumPy (or CuPY, depending on whether you have access to Cuda cores) and can be found in the `model` directory, which itself has two child folders.

**Pizza Classifier**
In `model/pizza_binary_classifier`, we have:
- `dataset` - Directory containing training and testing images for the model.
- `augment.py` - Python file that handles image augmentation. It takes every image in the dataset, crops it to a 1:1 aspect ratio, downscales its resolution to 64x64 pixels, and saves four copies of the image, one for each rotation by a multiple of 90 degrees. Downscaling the images makes it easier for the model to learn patterns, and saving rotated copies of the image helps avoid overfitting by enriching the dataset. The code here is slightly messier than some of my other code, but this file just prepares the data for the model and therefore only needs to be run once.
- `train.py` - Python file that trains the model on our pizza dataset. It loads the data, creates the model, trains the model on the data, and evaluates the model's accuracy on testing and training data.

**Model Source Code**
`model/src` contains the source code for the neural network used in this project. Each Python script here serves a distinct purpose.
- `activations.py` - Contains each activation function. In hidden layers, activation functions serve the purpose of introducing non-linearity. In output layers, activation functions serve the purpose of formatting the output to better represent the goal of the model. Here, for example, we use sigmoid, which maps the output to a probability representing the model's confidence in whether a given image contains a pizza or not.
- `layers.py` - Contains each layer type. So far, this file just includes dense / fully connected layers and dropout layers, but my intention is to continue adding different varieties of layer to this file. Dense layers are the standard layers used in neural networks, where every node in one layer is connected to every node in the next. Dropout layers help avoid overfitting the data by randomly setting node values to zero.
- `costs.py` - Contains each cost type. Each cost function is generally associated with a different deep learning task - We use binary crossentropy, which is suited for binary classification tasks.
- `model.py` - Contains the class for the actual model. The code here essentially brings together all of the logic in the other files to handle the large, over-arching tasks the model must accomplish, like forward passes for prediction calculations, backward passes for gradient calculations, updating parameters based on the gradient, configuring hyperparameters, etc. `model.py` also contains some helper functions to save and load parameters, shuffle data, make predictions, etc.
- `predictions.py` -  Contains a single helper function for formatting model predictions. My intention is to include more helper functions as I need them. 

I approached this part of the project with a few key design motivations:
- I wanted the scope of each file to be narrow and well-defined. Each file should serve to accomplish one focused task, and it should be immediately clear to anyone (with a sufficient background in DL) looking at the code what that task is and how it's implemented. This also improves the ease by which new features can be added. 
- I wanted to structure the project in such a way that use of the model was intuitive. For this, I looked to TensorFlow for inspiration, and if you've ever used TensorFlow, you might notice that the way you implement, train, and use a model here is fairly similar to the way you accomplish those tasks with TensorFlow.

The design pattern of introducing many, similarly-structured classes used in `layers.py`, `costs.py`, and `activations.py` serves a few purposes:
- It's important that layers and activation functions be able to maintain state. Certain layers have tunable parameters, for example, that need to be remembered throughout the training process.
- The consistent structure of each activation function, cost function, and layer type further improve the ease by which a developer would be able to add to the package.
- The class structure allows different costs and activations to use the same method names, simplifying their usage in `model.py`.

**Notes**
- The relatively sub-par performance of this model can mostly be attributed to the fact that I'm not using convolutional layers, which are the industry standard in image classification. Convolutional layers, unlike densely connected layers, are able to exploit the spatial relationships between elements of the input image while using less parameters.
- The `configure_inputs()` function contained within every script in `model/src` tells each script whether to use NumPy or CuPy. CuPy has a subset of the functionality of NumPy (which handles matrix math), but runs using Cuda cores on your GPU instead of cores on your CPU, making many calculations significantly faster.