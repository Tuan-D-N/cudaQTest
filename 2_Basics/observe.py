import cudaq
from cudaq import spin


import sys
# Add your custom path
custom_path = "../"
if custom_path not in sys.path:
    sys.path.append(custom_path)

try:
    from _cudaPythonNotation import *
except ImportError:
    pass


operator = spin.x(0)
print(operator)  # prints: [1+0j] Z


@cudaq.kernel
def kernel():
    qubit = cudaq.qubit()
    h(qubit)


print(cudaq.draw(kernel))
result = cudaq.observe(kernel, operator)
print(result.expectation())  # prints: 0.0

result = cudaq.observe(kernel, operator, shots_count=1000)
print(result.expectation())  # prints non-zero value
