#include <cudaq.h>
#include <cudaq/algorithms/draw.h>
#include <iostream>

__qpu__ void kernal(const int qubitCount)
{

    auto qvector = cudaq::qvector(qubitCount);

    cudaq::h(qvector[0]);

    for (int i : cudaq::range(1, qubitCount))
    {
        cudaq::x<cudaq::ctrl>(qvector[0], qvector[1]);
    }
}

int main(int argc, char const *argv[])
{
    int qubitCount = 2;
    std::cout << cudaq::draw(kernal, qubitCount);

    auto result = cudaq::sample(1000, kernal, qubitCount);

    result.dump();

    return 0;
}
