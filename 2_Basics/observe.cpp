#include <cudaq.h>
#include <cudaq/algorithm.h>

#include <iostream>

namespace sp = cudaq::spin;

__qpu__ void kernel()
{
    cudaq::qubit qubit;
    h(qubit);
}

int main()
{

    cudaq::spin_op spin_operator = sp::z(0);
    // Prints: [1+0j] Z
    std::cout << spin_operator.to_string() << "\n";

    auto result_0 = cudaq::observe(kernel, spin_operator);
    // Expectation value of kernel with respect to single `Z` term
    // should print: 0.0
    std::cout << "<kernel | spin_operator | kernel> = " << result_0.expectation()
              << "\n";
}