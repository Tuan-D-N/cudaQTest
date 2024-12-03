#include <iostream>
#include <cudaq.h>
#include <cudaq/algorithm.h>
#include <cudaq/algorithms/draw.h>
#include <cudaq/spin_op.h>

struct x_kernel
{
    auto operator()(cudaq::qubit &qubit) __qpu__
    {
        x(qubit);
    }
};

struct ccnot_test
{
    // constrain the signature of the incoming kernel
    void operator()(cudaq::takes_qubit auto &&apply_x) __qpu__
    {
        cudaq::qvector qs(3);

        x(qs);
        x(qs[1]);

        // Control U (apply_x) on the first two qubits of
        // the allocated register.
        cudaq::control(apply_x, qs.front(2), qs[2]);

        mz(qs);
    }
};

int main(int argc, char const *argv[])
{

    std::cout << cudaq::draw(ccnot_test{}, x_kernel{});
    auto results = cudaq::sample(ccnot_test{}, x_kernel{});
    results.dump();

    return 0;
}
