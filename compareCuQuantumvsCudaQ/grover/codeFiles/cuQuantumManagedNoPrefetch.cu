#include <chrono>
#include <iostream>
#include <string>
#include <custatevec.h> // custatevecInitializeStateVector
#include <cuComplex.h>
#include <random>
#include <stdio.h>
#include <cuda_runtime.h>
#include <cstdio>
#include <iomanip>

#define INV_SQRT2 (0.7071067811865475) // Approximation of 1/sqrt(2)

// Macro to check CUDA API errors
#define CHECK_CUDA(func)                                                          \
    {                                                                             \
        cudaError_t status = (func);                                              \
        if (status != cudaSuccess)                                                \
        {                                                                         \
            printf("CUDA API failed at line %d in file %s with error: %s (%d)\n", \
                   __LINE__, __FILE__, cudaGetErrorString(status), status);       \
            return EXIT_FAILURE;                                                  \
        }                                                                         \
    }

// Macro to check cuSPARSE API errors
#define CHECK_CUSPARSE(func)                                                     \
    {                                                                            \
        cusparseStatus_t status = (func);                                        \
        if (status != CUSPARSE_STATUS_SUCCESS)                                   \
        {                                                                        \
            printf("CUSPARSE API failed at line %d in file %s with error: %d\n", \
                   __LINE__, __FILE__, status);                                  \
            return EXIT_FAILURE;                                                 \
        }                                                                        \
    }

// Macro to check cuSPARSE API errors
#define CHECK_CUSTATEVECTOR(func)                                                     \
    {                                                                                 \
        custatevecStatus_t status = (func);                                           \
        if (status != CUSTATEVEC_STATUS_SUCCESS)                                      \
        {                                                                             \
            printf("CUSTATEVECTOR API failed at line %d in file %s with error: %d\n", \
                   __LINE__, __FILE__, status);                                       \
            return EXIT_FAILURE;                                                      \
        }                                                                             \
    }

#define CHECK_BROAD_ERROR(integer)                                    \
    {                                                                 \
        if (integer != 0)                                             \
        {                                                             \
            printf("Broad CUDA ERROR failed at line %d in file %s\n", \
                   __LINE__, __FILE__);                               \
            return EXIT_FAILURE;                                      \
        }                                                             \
    }

void generateRandomArray(double *arr, std::size_t size)
{
    std::random_device rd;                                   // Seed
    std::mt19937 gen(rd());                                  // Mersenne Twister RNG
    std::uniform_real_distribution<double> dist(0.0f, 1.0f); // Range [0, 1)

    for (std::size_t i = 0; i < size; ++i)
    {
        arr[i] = dist(gen);
    }
}

int main(int argc, char const *argv[])
{
    const int nIndexBits = 1 < argc ? atoi(argv[1]) : 30;
    // const auto cuStateVecComputeType = CUSTATEVEC_COMPUTE_64F;
    // auto cuStateVecCudaDataType = CUDA_C_64F;
    // using cuType = cuDoubleComplex;
    using cuType = cuComplex;
    const auto cuStateVecComputeType = CUSTATEVEC_COMPUTE_32F;
    const auto cuStateVecCudaDataType = CUDA_C_32F;

    const int svSize = (1 << nIndexBits);

    const int nShots = 100;
    const int nMaxShots = nShots;
    std::vector<int> bitOrdering = std::vector<int>(nIndexBits, 0);
    for (int i = 0; i < nIndexBits; ++i)
    {
        bitOrdering[i] = i;
    }
    const int bitStringLen = nIndexBits;
    custatevecIndex_t bitStrings[nShots];
    double randnums[nShots] = {};
    generateRandomArray(randnums, nShots);

    cuType xMat[] = {{0.0, 0.0}, {1.0, 0.0}, {1.0, 0.0}, {0.0, 0.0}};
    cuType zMat[] = {{1.0, 0.0}, {0.0, 0.0}, {0.0, 0.0}, {-1.0, 0.0}};
    cuType hMat[] = {{INV_SQRT2, 0.0}, {INV_SQRT2, 0.0}, {INV_SQRT2, 0.0}, {-INV_SQRT2, 0.0}};

    cuType *d_sv;
    CHECK_CUDA(cudaMallocManaged((void **)&d_sv, svSize * sizeof(cuType)));

    //----------------------------------------------------------------------------------------------

    {
        auto start_m = std::chrono::high_resolution_clock::now();

        // std::vector<int> controlsAll = std::vector<int>(nIndexBits, 0);
        std::vector<int> controlsAllExceptLast = std::vector<int>(nIndexBits - 1, 0);
        int markTargets[] = {nIndexBits - 1};
        for (int i = 0; i < nIndexBits - 1; ++i)
        {
            // controlsAll[i] = i;
            controlsAllExceptLast[i] = i;
        }
        // controlsAll[nIndexBits - 1] = nIndexBits - 1;

        // custatevec handle initialization
        custatevecSamplerDescriptor_t sampler;
        custatevecHandle_t handle;
        CHECK_CUSTATEVECTOR(custatevecCreate(&handle));
        void *extraWorkspace = nullptr;
        size_t extraWorkspaceSizeInBytes = 0;

        // Init to zero state
        cudaMemPrefetchAsync(d_sv, svSize * sizeof(cuType), cudaCpuDeviceId);
        d_sv[0] = {1, 0};
        for (int i = 1; i < svSize; ++i)
        {
            d_sv[i] = {0, 0};
        }

        // Prefetch memory to the GPU
        int device;
        CHECK_CUDA(cudaGetDevice(&device)); // Get the current GPU device
        std::cout << "Current GPU: " << device << "\n";
        cudaMemPrefetchAsync(d_sv, svSize * sizeof(cuType), device);

        // H to all qubits
        for (int i = 0; i < nIndexBits; ++i)
        {
            int targets[] = {i};
            CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                handle, d_sv, cuStateVecCudaDataType, nIndexBits, hMat, cuStateVecCudaDataType,
                CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, targets, 1, {}, nullptr,
                0, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
        }
        // H to all qubits

        for (int i = 0; i < 10; ++i)
        {
            // mark
            CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                handle, d_sv, cuStateVecCudaDataType, nIndexBits, zMat, cuStateVecCudaDataType,
                CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, markTargets, 1, controlsAllExceptLast.data(), nullptr,
                nIndexBits - 1, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
            // Diffusion
            // H->all, X->all, cz->allexceptLast mark, x->all, H->all
            for (int j = 0; j < nIndexBits; ++j)
            {
                int targets[] = {j};
                CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                    handle, d_sv, cuStateVecCudaDataType, nIndexBits, hMat, cuStateVecCudaDataType,
                    CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, targets, 1, {}, nullptr,
                    0, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
            }
            for (int j = 0; j < nIndexBits; ++j)
            {
                int targets[] = {j};
                CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                    handle, d_sv, cuStateVecCudaDataType, nIndexBits, xMat, cuStateVecCudaDataType,
                    CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, targets, 1, {}, nullptr,
                    0, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
            }
            CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                handle, d_sv, cuStateVecCudaDataType, nIndexBits, zMat, cuStateVecCudaDataType,
                CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, markTargets, 1, controlsAllExceptLast.data(), nullptr,
                nIndexBits - 1, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
            for (int j = 0; j < nIndexBits; ++j)
            {
                int targets[] = {j};
                CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                    handle, d_sv, cuStateVecCudaDataType, nIndexBits, xMat, cuStateVecCudaDataType,
                    CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, targets, 1, {}, nullptr,
                    0, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
            }
            for (int j = 0; j < nIndexBits; ++j)
            {
                int targets[] = {j};
                CHECK_CUSTATEVECTOR(custatevecApplyMatrix(
                    handle, d_sv, cuStateVecCudaDataType, nIndexBits, hMat, cuStateVecCudaDataType,
                    CUSTATEVEC_MATRIX_LAYOUT_ROW, 0, targets, 1, {}, nullptr,
                    0, cuStateVecComputeType, extraWorkspace, extraWorkspaceSizeInBytes));
            }
        }

        // create sampler and check the size of external workspace
        CHECK_CUSTATEVECTOR(custatevecSamplerCreate(
            handle, d_sv, cuStateVecCudaDataType, nIndexBits, &sampler, nMaxShots,
            &extraWorkspaceSizeInBytes));

        // allocate external workspace if necessary
        if (extraWorkspaceSizeInBytes > 0)
            CHECK_CUDA(cudaMalloc(&extraWorkspace, extraWorkspaceSizeInBytes));

        // sample preprocess
        CHECK_CUSTATEVECTOR(custatevecSamplerPreprocess(
            handle, sampler, extraWorkspace, extraWorkspaceSizeInBytes));

        // sample bit strings
        CHECK_CUSTATEVECTOR(custatevecSamplerSample(
            handle, sampler, bitStrings, bitOrdering.data(), bitStringLen, randnums, nShots,
            CUSTATEVEC_SAMPLER_OUTPUT_ASCENDING_ORDER));

        // destroy descriptor and handle
        CHECK_CUSTATEVECTOR(custatevecSamplerDestroy(sampler));

        //  destroy handle
        CHECK_CUSTATEVECTOR(custatevecDestroy(handle));
        if (extraWorkspaceSizeInBytes)
            CHECK_CUDA(cudaFree(extraWorkspace));

        auto stop_m = std::chrono::high_resolution_clock::now();
        auto duration_m = std::chrono::duration<double>(stop_m - start_m);
        std::cout << "Time = " << duration_m.count() << std::endl;
    }
    //----------------------------------------------------------------------------------------------
    cudaMemPrefetchAsync(d_sv, svSize * sizeof(cuType), cudaCpuDeviceId);
    for (int i = svSize - 1; i < svSize; ++i)
    {
        // std::cout << std::fixed << std::setprecision(15) << "(" << d_sv[i].x << "," << d_sv[i].y << ")" << "\n";
    }
    // std::cout << "\n\n\n";

    // printDeviceArray(d_sv, svSize);
    CHECK_CUDA(cudaFree(d_sv));

    return EXIT_SUCCESS;
}