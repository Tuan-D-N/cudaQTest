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
    auto hamiltonian = spin::z(0) + spin::y(1) + spin::x(0) * spin::z(0);

    auto result = cudaq::observe(kernel, hamiltonian, qubit_count).expectation();

    std::cout << '<H> =' << result << std::endl;

    return 0;
}
