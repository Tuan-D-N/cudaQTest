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

int main()
{

  int qubit_count = 2;
  auto result_0 = cudaq::sample(kernel, /* kernel args */ qubit_count);
  // Should see a roughly 50/50 distribution between the |00> and
  // |11> states. Example: {00: 505  11: 495}
  result_0.dump();

  int shots_count = 10000;
  auto result_1 = cudaq::sample(shots_count, kernel, qubit_count);
  result_1.dump();
}