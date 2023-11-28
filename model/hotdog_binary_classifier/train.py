# I know I should be doing this in a Jupyter or Colab Notebook. Sue me.
# -- IN PROGRESS --
import cv2
import cupy as np
import os
from sandbox import activations, costs, layers, predictions, model

# Load altered hotdog data - https://www.kaggle.com/datasets/dansbecker/hot-dog-not-hot-dog
dataset_path = 'C:\\Users\\kayde\\OneDrive\\Documents\\AI\\neural-network\\neural-network\\examples\\hotdog_binary_classifier\\dataset\\altered\\'
datasets = [
    np.array([
        cv2.imread(dataset_path + dir + img).flatten()
        for img in os.listdir(dataset_path + dir)
    ])
    for dir in ['train\\hotdog\\', 'train\\nothotdog\\', 'test\\hotdog\\', 'test\\nothotdog\\']
]

train_x = np.concatenate((datasets[0], datasets[1]), axis=0) / 255
train_y = np.concatenate((np.ones((datasets[0].shape[0], 1)), np.zeros((datasets[1].shape[0], 1))), axis=0)

test_x = np.concatenate((datasets[2], datasets[3]), axis=0) / 255
test_y = np.concatenate((np.ones((datasets[2].shape[0], 1)), np.zeros((datasets[3].shape[0], 1))), axis=0)

# Create model

model = model.Model(cuda=True)
model.add(layers.Dense(units=50, activation=activations.ReLU()))
model.add(layers.Dense(units=20, activation=activations.ReLU()))
model.add(layers.Dense(units=5, activation=activations.ReLU()))
model.add(layers.Dense(units=1, activation=activations.Sigmoid()))

model.configure(learning_rate=0.01, epochs=10000, cost_type=costs.BinaryCrossentropy())
model.train(train_x, train_y, verbose=True)

# Assess model accuracy
pred_train = model.predict(train_x, prediction_type=predictions.binary_classification) # Get model accuracy on training data
print('\nTraining Accuracy: '  + str(np.sum((pred_train == train_y)/train_x.shape[0])))
pred_test = model.predict(test_x, prediction_type=predictions.binary_classification) # Get model accuracy on testing data
print('Testing Accuracy: '  + str(np.sum((pred_test == test_y)/test_x.shape[0])))
