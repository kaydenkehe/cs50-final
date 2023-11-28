# Handle conditional imports
def configure_imports(cuda):
    global np
    np = __import__('cupy' if cuda else 'numpy')

# 1 if output > 0.5, 0 otherwise
def binary_classification(Y):
    return np.where(Y > 0.5, 1, 0)
