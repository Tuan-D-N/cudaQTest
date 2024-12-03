import cudaq
import numpy as np

qubit_count = 2

# Define the simulation target.
cudaq.set_target("qpp-cpu")

# Define a quantum kernel function.


@cudaq.kernel
def kernel(qubit_count: int):
    qvector = cudaq.qvector(qubit_count)

    # 2-qubit GHZ state.
    h(qvector[0])
    for i in range(1, qubit_count):
        x.ctrl(qvector[0], qvector[i])

    # If we dont specify measurements, all qubits are measured in
    # the Z-basis by default or we can manually specify it also
    # mz(qvector)


print(cudaq.draw(kernel, qubit_count))

result = cudaq.sample(kernel, qubit_count, shots_count=1000)

print(result)
