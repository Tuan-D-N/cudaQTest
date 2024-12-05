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
        auto qvector = cudaq::qvector(qubit_count - 1);
        auto qfinal = cudaq::qubit();

        cudaq::h(qvector);
        cudaq::h(qfinal);

        for (int i = 0; i < 10; i++)
        {
            // Mark
            cudaq::z<cudaq::ctrl>(qvector, qfinal);

            // Diffusion
            cudaq::h(qvector);
            cudaq::h(qfinal);
            cudaq::x(qvector);
            cudaq::x(qfinal);
            cudaq::z<cudaq::ctrl>(qvector, qfinal);
            cudaq::x(qvector);
            cudaq::x(qfinal);
            cudaq::h(qvector);
            cudaq::h(qfinal);
        }
        cudaq::mz(qvector);
        cudaq::mz(qfinal);
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
    std::cout << "Qubits = " << qubit_count << std::endl;
    std::cout << "It took " << duration.count() << " seconds.\n";
    return 0;
}
