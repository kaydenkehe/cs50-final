# I know I should be doing this in a Jupyter or Colab Notebook. Sue me.
# -- IN PROGRESS --
import cv2
import cupy as np
from os import chdir, path, listdir
from sandbox import activations, costs, layers, predictions, model

chdir(path.dirname(path.abspath(__file__)))

# Load altered hotdog data - https://www.kaggle.com/datasets/dansbecker/hot-dog-not-hot-dog
dataset_path = 'dataset\\altered\\'
datasets = [
    np.array([
        cv2.imread(dataset_path + dir + img).flatten()
        for img in listdir(dataset_path + dir)
    ])
    for dir in ['train\\pizza\\', 'train\\not_pizza\\', 'test\\pizza\\', 'test\\not_pizza\\']
]

train_x = np.concatenate((datasets[0], datasets[1]), axis=0) / 255
train_y = np.concatenate((np.ones((datasets[0].shape[0], 1)), np.zeros((datasets[1].shape[0], 1))), axis=0)

test_x = np.concatenate((datasets[2], datasets[3]), axis=0) / 255
test_y = np.concatenate((np.ones((datasets[2].shape[0], 1)), np.zeros((datasets[3].shape[0], 1))), axis=0)

# Create model
model = model.Model(cuda=True)
model.add(layers.Dense(units=32, activation=activations.ReLU()))
model.add(layers.Dense(units=16, activation=activations.ReLU()))
model.add(layers.Dense(units=8, activation=activations.ReLU()))
model.add(layers.Dense(units=1, activation=activations.Sigmoid()))

model.configure(learning_rate=0.01, epochs=2000, cost_type=costs.BinaryCrossentropy())
model.train(train_x, train_y, verbose=True)
model.save(name='parameters.json', dir='..\\..\\backend\\')

# Assess model accuracy
pred_train = model.predict(train_x, prediction_type=predictions.binary_classification) # Get model accuracy on training data
print('\nTraining Accuracy: ' + str(np.round(np.sum((pred_train == train_y)/train_x.shape[0]), decimals=5)))
pred_test = model.predict(test_x, prediction_type=predictions.binary_classification) # Get model accuracy on testing data
print('Testing Accuracy: ' + str(np.round(np.sum((pred_test == test_y)/test_x.shape[0]), decimals=5)))
