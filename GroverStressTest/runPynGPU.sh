#!/bin/bash --login


load_modules_for cudaq

fileNm=$1
numGPU=$2
baseNm=$(basename "$fileNm" .py)
resultDIR="groverResults"

for repeat in {1..5}
do
    for qubit in $(seq 10 5 20)
    do
        srun --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) python3 $fileNm $qubit >> ${resultDIR}/${baseNm}_${numGPU}GPU
    done
done

for repeat in {1..5}
do
    for qubit in $(seq 21 1 60)
    do
        srun --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) python3 $fileNm $qubit >> ${resultDIR}/${baseNm}_${numGPU}GPU
    done
done