#include <iostream>
#include <cudaq.h>
#include <cudaq/algorithm.h>
#include <cudaq/algorithms/draw.h>
#include <cudaq/spin_op.h>

__qpu__ void x_kernel(cudaq::qubit &qubit)
{
    x(qubit);
}

__qpu__ void kernel()
{
    auto control_vector = cudaq::qvector(2);
    auto target = cudaq::qubit();

    cudaq::x(control_vector);
    cudaq::x(target);
    cudaq::x(control_vector[1]);
    cudaq::control(x_kernel, control_vector, target);
}

int main(int argc, char const *argv[])
{
    std::cout << cudaq::draw(kernel);

    auto results = cudaq::sample(1000, kernel);
    results.dump();

    return 0;
}
