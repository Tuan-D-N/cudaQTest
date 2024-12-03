#include <cudaq.h>
#include <cudaq/spin_op.h>
#include <iostream>

__qpu__ void kernel(int qubit_count)
{
    auto qvector = cudaq::qvector(qubit_count);

    cudaq::h(qvector[0]);

    for (int i : cudaq::range(1, qubit_count))
    {
        cudaq::x<cudaq::ctrl>(qvector[0], qvector[i]);
    }
}

int main(int argc, char const *argv[])
{
    int qubit_count = 2;
    namespace spin = cudaq::spin;

    auto result = cudaq::get_state(kernel, qubit_count);

    result.dump();

    return 0;
}
