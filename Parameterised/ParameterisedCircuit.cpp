#include <iostream>
#include <cudaq.h>
#include <tuple>
#include <cudaq/spin_op.h>
#include <cudaq/algorithms/draw.h>
#include <cudaq/gradients.h>
#include <cudaq/optimizers.h>

struct kernel
{
    auto operator()(std::vector<double> angles) __qpu__
    {
        auto qubits = cudaq::qvector(2);

        cudaq::x(qubits[0]);
        cudaq::ry(angles[0], qubits[1]);
        cudaq::x<cudaq::ctrl>(qubits[1], qubits[0]);
    }
};

double terrain(const std::vector<double> &inputVector)
{
    namespace sp = cudaq::spin;
    cudaq::spin_op hamiltonian = 5.907 - 2.1433 * sp::x(0) * sp::x(1) - 2.1433 * sp::y(
    0) * sp::y(1) + .21829 * sp::z(0) - 6.125 * sp::z(1);
    auto objectResult = cudaq::observe(kernel{}, hamiltonian, inputVector);
    return objectResult.expectation();
}

double objectiveFunction(const std::vector<double> &inputVector, std::vector<double> &gradient)
{

    double resultAtX = terrain(inputVector);
    auto gradientFunction = cudaq::gradients::central_difference();
    gradientFunction.step = 0.01;
    gradient = gradientFunction.compute(inputVector, terrain, resultAtX);

    return resultAtX;
}

int main(int argc, char const *argv[])
{

    cudaq::optimizers::gradient_descent optimizer = cudaq::optimizers::gradient_descent();
    
    optimizer.max_eval = 10000;

    auto result = optimizer.optimize(1, cudaq::optimizable_function(objectiveFunction));

    auto energy = std::get<0>(result);
    auto params = std::get<1>(result);

    auto inVec = std::vector<double>{0};
    auto outVec = std::vector<double>{};
    std::cout << cudaq::draw(kernel{}, inVec);
    std::cout << "terrain: " << objectiveFunction(inVec, outVec) << "\n";
    std::cout << "out[0]: " << outVec[0] << "\n";
    cudaq::get_state(kernel{}, inVec).dump();

    std::cout << "energy: " << energy << "\n";
    std::cout << "params[0]: " << params[0] << "\n";
    return 0;
}
