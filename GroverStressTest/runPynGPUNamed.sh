#!/bin/bash --login


load_modules_for cudaq

numGPU=$1
cppFiles=$(ls *.o)
pythonFiles=$(ls *.py)

for fileNm in $@

    do

    baseNm=$(basename "$fileNm" .py)
    resultDIR="groverResults"

    for repeat in {1..5}
    do
        for qubit in $(seq 10 5 30)
        do
            srun --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) python3 $fileNm $qubit >> ${resultDIR}/${baseNm}_${numGPU}GPU
        done
    done

    for repeat in {1..5}
    do
        for qubit in $(seq 31 1 60)
        do
            srun --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) python3 $fileNm $qubit >> ${resultDIR}/${baseNm}_${numGPU}GPU
        done
    done

done
