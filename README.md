# Pizza Classifier - User Manual

This document will walk you through how to setup and use the pizza classification app as well as the deep learning model.

## Using the App
These instructions assume that you intend to use VSCode, and that you intend to run the app on your own personal Android device, as I did (as opposed to using a different operating system, like IOS, or an emulator).

**Running the Server**

- If you haven't already, install [Python]( https://www.python.org/downloads/) on your system. Ensure that you select the option to install Pip when it appears. I'm using Python version 3.11.3, but any version 3 or above should work.
- If you haven't already, install [VSCode](https://code.visualstudio.com/download). Upon installing VSCode, open the project folder and install the Python extension.
- In your VSCode terminal, ensure that you're in the top-level project directory (you should be able to see the `model`, `frontend`, and `backend` folders), and run the command `pip install -r requirements.txt` in your VSCode terminal to install the necessary Python packages.
- Run `app.py`.

**Installing the App**

The specific instructions here would vary by phone model and operating system, so these instructions are intentionally vague and may require additional research for those who aren't tech-savvy.

- Install [Flutter](https://docs.flutter.dev/get-started/install), [Dart](https://docs.flutter.dev/get-started/install), and [Android Studio](https://developer.android.com/studio).
- Add the path to the `bin` folders in your Flutter and Dart installations to your `Path` system environment variable.
- Install the Flutter and Dart VSCode extensions.
- Ensure that Flutter is operating correctly by using the `flutter doctor` command in your VSCode terminal. Disregard issues related to compiling to web or desktop.
- On your Android device, access your developer options and enable USB debugging.
- Connect your phone to your laptop via a USB cable, click 'allow' on your phone, run `flutter devices` in your VSCode terminal to ensure that Flutter has detected your phone, and run `flutter run` to compile the app to your phone.

**Using the App**

The app is relatively simple, and use of it should be fairly intuitive. Upon first launching the app, you'll be greeted with a login screen, where you should either log in or register a new account with a username and password. Once you've successfully logged in to the app, you'll be greeted with a view of your camera, where you can take photos and have our model guess whether your photo contains pizza or not!

## Using the Model

**Setup**

Install the package: `python -m pip install -e $path to /src$`

**Usage**

Import required packages:
```{python}
from sandbox import model, layers, activations, costs, predictions
```

Create the model:
```{python}
model = model.Model()
```

Add layers to the model:
```{python}
model.add(layers.Dense(units=20, activation=activations.ReLU()))
model.add(layers.Dense(units=7, activation=activations.ReLU()))
model.add(layers.Dense(units=5, activation=activations.ReLU()))
model.add(layers.Dense(units=1, activation=activations.Sigmoid()))
```

Configure the model:
```{python}
model.configure(learning_rate=0.0075, epochs=2500, cost_type=costs.BinaryCrossentropy())
```

Train the model:
```{python}
model.train(train_x, train_y, verbose=True)
```

Predict with the model:
```{python}
pred = model.predict(image, prediction_type=predictions.binary_classification)
```

**General Abilities:**
- Binary Classification

**Activation Functions**
- Linear
- Sigmoid
- ReLU
- Tanh
- Heaviside
- Signum
- ELU (Exponential Linear Units)
- SELU (Scaled Exponential Linear Units)
- SLU (Sigmoid Linear Units)
- Softplus
- Softsign
- BentIdentity
- Gaussian
- Arctan
- PiecewiseLinear
- DoubleExponential

**Cost Functions**
- BinaryCrossentropy
- MSE (Mean Squared Error)
- MAE (Mean Absolute Error)

**Layer Types**
- Dense (fully connected)
- Dropout
