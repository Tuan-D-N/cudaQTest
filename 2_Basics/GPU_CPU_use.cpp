#include <cudaq.h>
#include <iostream>

__qpu__ void kernel(int qubit_count)
{
    // Allocate our qubits.
    cudaq::qvector qvector(qubit_count);
    // Place the first qubit in the superposition state.
    h(qvector[0]);
    // Loop through the allocated qubits and apply controlled-X,
    // or CNOT, operations between them.
    for (auto qubit : cudaq::range(qubit_count - 1))
    {
        x<cudaq::ctrl>(qvector[qubit], qvector[qubit + 1]);
    }
    // Measure the qubits.
    mz(qvector);
}

int main(int argc, char *argv[])
{
    auto qubit_count = 1 < argc ? atoi(argv[1]) : 25;
    auto shots_count = 1000000;
    auto start = std::chrono::high_resolution_clock::now();

    // Timing just the sample execution.
    auto result = cudaq::sample(shots_count, kernel, qubit_count);

    auto stop = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(stop - start);
    std::cout << "It took " << duration.count() << " seconds.\n";
}
// Compile with nvq++ filename -o fileout --target=nvidia defult
// Compile with nvq++ filename -o fileout --target=qpp-cpu