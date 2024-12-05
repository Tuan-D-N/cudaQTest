#include <iostream>
#include <cudaq.h>
#include <cudaq/spin_op.h>
#include <cudaq/algorithms/draw.h>

struct ApplyZ
{
    auto operator()(cudaq::qubit &q) __qpu__
    {
        cudaq::z(q);
    }
};

struct kernel
{
    auto operator()(int qubit_count) __qpu__
    {
        // superposition
        auto qvector = cudaq::qvector(qubit_count);
        cudaq::h(qvector);

        for (int i = 0; i < 10; i++)
        {
            // Mark
            cudaq::control(ApplyZ{}, qvector.front(qubit_count - 1), qvector.back());

            // Diffusion
            cudaq::h(qvector);
            cudaq::x(qvector);
            cudaq::control(ApplyZ{}, qvector.front(qubit_count - 1), qvector.back());
            cudaq::x(qvector);
            cudaq::h(qvector);
        }
        cudaq::mz(qvector);
    }
};

int main(int argc, char const *argv[])
{
    auto qubit_count = 1 < argc ? atoi(argv[1]) : 25;

    cudaq::draw(kernel{}, qubit_count);

    auto shots_count = 100;
    auto start = std::chrono::high_resolution_clock::now();

    // Timing just the sample execution.
    auto result = cudaq::sample(shots_count, kernel{}, qubit_count);

    auto stop = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(stop - start);
    // std::cout << "Qubits = " << qubit_count << std::endl;
    // std::cout << "It took " << duration.count() << " seconds.\n";
    std::cout << qubit_count << "," << duration.count() << std::endl;
    return 0;
}
