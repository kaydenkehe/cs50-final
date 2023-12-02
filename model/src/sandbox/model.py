import json

# Handle conditional imports
def configure_imports(cuda):
    global np
    np = __import__('cupy' if cuda else 'numpy')

class Model:
    layers = [] # Each item is a layer object
    parameters = [] # Each item is a dictionary with a 'W' and 'b' matrix for the weights and biases respectively
    caches = [] # Each item is a dictionary with the 'A_prev', 'W', 'b', and 'Z' values for the layer - Used in backprop
    costs = [] # Each item is the cost for the epoch

    def __init__(self, cuda=False):
        # Run 'configure_imports()' in all modules in sandbox
        # I dislike this solution.
        # TODO: Make this less shitty
        import sandbox, inspect
        for module, _ in inspect.getmembers(sandbox, inspect.ismodule):
            exec(f'sandbox.{module}.configure_imports(cuda)')

    # Add layer to model
    def add(self, layer):
        self.layers.append(layer)

    # Configure model parameters
    def configure(self, cost_type, learning_rate = 0.0075, epochs = 3000):
        self.cost_type = cost_type
        self.learning_rate = learning_rate
        self.epochs = epochs

    # Train model
    def train(self, X, Y, verbose=False):
        X, Y = X.T, Y.T # Transpose X and Y to match shape of weights and biases
        self.initialize_parameters(input_size=X.shape[0]) # Initialize random parameters
        self.costs = []

        # Loop through epochs
        for i in range(self.epochs + 1):
            X, Y = self.shuffle(X, Y) # Shuffle data
            AL = self.forward_pass(X) # Forward propagate
            cost = self.cost_type.forward(AL, Y) # Calculate cost
            grads = self.backward_pass(AL, Y, self.cost_type) # Calculate gradient
            self.update_parameters(grads, self.learning_rate) # Update weights and biases
            self.costs.append(cost) # Update costs list
            
            if verbose and i % 100 == 0 or i == self.epochs:
                print(f"Cost on epoch {i}: {round(cost.item(), 5)}") # Optional, output progress

    # Initialize weights and biases
    def initialize_parameters(self, input_size):
        # We only want to initialize parameters for trainable layers (excluding dropout, for example)
        trainable_layers = [layer for layer in self.layers if layer.trainable]

        # We start on layer -1 to handle the parameters connecting the input layer to the first hidden layer
        self.parameters = [{
            'W': np.random.randn(trainable_layers[layer + 1].units, trainable_layers[layer].units if layer != -1 else input_size) / np.sqrt(trainable_layers[layer].units if layer != -1 else input_size), # Gaussian random dist for weights
            'b': np.zeros((trainable_layers[layer + 1].units, 1)) # Zeros for biases
        } for layer in range(-1, len(trainable_layers) - 1)]

        # For non-train layers, we want to set the parameters to empty arrays
        for layer in range(len(self.layers)):
            if not self.layers[layer].trainable:
                self.parameters.insert(layer, {'W': np.array([]), 'b': np.array([])})

    # Shuffle data
    def shuffle(self, X, Y):
        assert X.shape[1] == Y.shape[1]
        permutation = np.random.permutation(X.shape[1])
        return X[:, permutation], Y[:, permutation]

    # Forward propagate through model
    def forward_pass(self, A, train=True):
        self.caches = []

        # Exclude non-trainable layers like dropout when not training
        layers = [i for i in range(len(self.layers)) if self.layers[i].trainable or train]
        
        # Loop through hidden layers, calculating activations
        for layer in layers:
            A_prev = A
            A, Z = self.layers[layer].forward(A_prev, **self.parameters[layer])
            self.caches.append({
                'A_prev': A_prev,
                "W": self.parameters[layer]['W'],
                "b": self.parameters[layer]['b'],
                "Z": Z
            })

        return A

    # Find derivative with respect to each activation, weight, and bias
    def backward_pass(self, AL, Y, cost):
        grads = [None] * len(self.layers)
        dA_prev = cost.backward(AL, Y.reshape(AL.shape)) # Find derivative of cost with respect to final activation
        
        # Find dA, dW, and db for all layers
        for layer in reversed(range(len(self.layers))):
            cache = self.caches[layer]
            dA_prev, dW, db = self.layers[layer].backward(dA_prev, **cache)
            grads[layer] = {'dW': dW, 'db': db}
            
        return grads

    # Update parameters using gradient
    def update_parameters(self, grads, learning_rate):
        for layer in range(len(self.layers)):
            if self.layers[layer].trainable:
                self.parameters[layer]['b'] -= learning_rate * grads[layer]['db'] # Update biases for layer
                self.parameters[layer]['W'] -= learning_rate * grads[layer]['dW'] # Update weights for layer

    # Predict given input values and weights / biases
    def predict(self, X, prediction_type=lambda x: x):
        prediction = self.forward_pass(X.T, train=False).T # Model outputs
        return prediction_type(prediction)

    # Save parameters to JSON file
    def save(self, name='parameters.json', dir=''):
        jsonified_params = [
            {'W': layer['W'].tolist(), 'b': layer['b'].tolist()}
            for layer in [layer for layer in self.parameters if layer['W'].size != 0] # Exclude empty arrays (for dropout layers, for example)
        ]
        with open(dir + name, 'w') as file:
            json.dump(jsonified_params, file)

    # Load parameters from JSON file
    def load(self, name='parameters.json', dir=''):
        with open(dir + name, 'r') as file:
            jsonified_params = json.load(file)
        self.parameters = [{'W': np.array(layer['W']), 'b': np.array(layer['b'])} for layer in jsonified_params]
