#include <iostream>
#include <cudaq.h>
#include <cudaq/spin_op.h>
#include <cudaq/algorithms/draw.h>
#include <iomanip>

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
    }
};

int main(int argc, char const *argv[])
{
    auto qubit_count = 1 < argc ? atoi(argv[1]) : 30;

    cudaq::draw(kernel{}, qubit_count);

    auto shots_count = 100;
    auto start = std::chrono::high_resolution_clock::now();

    // Timing just the sample execution.
    auto result = cudaq::sample(shots_count, kernel{}, qubit_count);

    auto stop = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration<double>(stop - start);
    // std::cout << "Qubits = " << qubit_count << std::endl;
    // std::cout << "It took " << duration.count() << " seconds.\n";

    auto state = cudaq::get_state(kernel{}, qubit_count);

    // auto& precisionout = std::cout << std::fixed << std::setprecision(15);
    // state.dump(precisionout);

    std::vector<std::vector<int>> basisStates;
    basisStates.emplace_back(qubit_count, 1);
    std::cout << basisStates[0].size() << "\n";

    auto lastAmp = state.amplitudes(basisStates).back();

    std::cout << "(" << lastAmp.real() << "," << lastAmp.imag() << ")" << "\n";
    std::cout << (int)state.get_precision() << "\n";

    std::cout << qubit_count << "," << duration.count() << std::endl;
    std::cout << "\n\n\n";
    return 0;
}
