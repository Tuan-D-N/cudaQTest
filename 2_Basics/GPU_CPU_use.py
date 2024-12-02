import sys
import timeit
import cudaq


import sys
# Add your custom path
custom_path = "../"
if custom_path not in sys.path:
    sys.path.append(custom_path)
try:
    from _cudaPythonNotation import *
except ImportError:
    pass


# Define our kernel.
@cudaq.kernel
def kernel(qubit_count: int):
    # Allocate our qubits.
    qvector = cudaq.qvector(qubit_count)
    # Place the first qubit in the superposition state.
    h(qvector[0])
    # Loop through the allocated qubits and apply controlled-X,
    # or CNOT, operations between them.
    for qubit in range(qubit_count - 1):
        x.ctrl(qvector[qubit], qvector[qubit + 1])
    # Measure the qubits.
    mz(qvector)


# Will time the execution of our sample call.
code_to_time = 'cudaq.sample(kernel, qubit_count, shots_count=1000000)'
qubit_count = int(sys.argv[1]) if 1 < len(sys.argv) else 25

# Execute on CPU backend.
cudaq.set_target('qpp-cpu')
print('CPU time')  # Example: 27.57462 s.
print(timeit.timeit(stmt=code_to_time, globals=globals(), number=1))

if cudaq.num_available_gpus() > 0:
    # Execute on GPU backend.
    cudaq.set_target('nvidia')
    print('GPU time')  # Example: 0.773286 s.
    print(timeit.timeit(stmt=code_to_time, globals=globals(), number=1))
