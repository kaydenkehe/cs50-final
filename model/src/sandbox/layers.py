# Handle conditional imports
def configure_imports(cuda):
    global np
    np = __import__('cupy' if cuda else 'numpy')

# Dense / fully connected layer
class Dense():
    def __init__(self, units, activation):
        self.trainable = True
        self.units = units
        self.activation = activation

    # Calculate layer neuron activations phi(W^T * A + b)
    def forward(self, A_prev, W, b):
        Z = np.dot(W, A_prev) + b # Compute Z
        A = self.activation.forward(Z) # Compute A using the given activation function

        return A, Z
    
    # Find derivative with respect to weights, biases, and activations for a particular layer
    def backward(self, dA, A_prev, W, b, Z):
        m = A_prev.shape[1]
        dZ = dA * self.activation.backward(Z) # Evaluate dZ using the derivative of activation function
        dW = 1 / m * np.dot(dZ, A_prev.T) # Calculate derivative with respect to weights
        db = 1 / m * np.sum(dZ, axis=1, keepdims=True) # Calculate derivative with respect to biases
        dA_prev = np.dot(W.T, dZ) # Calculate derivative with respect to the activation of the previous layer

        return dA_prev, dW, db

# Dropout layer
class Dropout():
    def __init__(self, rate):
        self.trainable = False
        self.rate = rate
        self.mask = None

    # Randomly set activations to 0
    def forward(self, A, W, b):
        self.mask = np.where(np.random.rand(*A.shape) > self.rate, 1, 0)
        A = np.multiply(A, self.mask)

        return A, None
    
    # Set activation derivatives to 0 if they were set to 0 during forward propagation
    def backward(self, dA, A_prev, W, b, Z):
        dA_prev = np.multiply(dA, self.mask)

        return dA_prev, None, None
