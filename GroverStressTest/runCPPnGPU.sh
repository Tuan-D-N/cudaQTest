#!/bin/bash --login


load_modules_for cudaq

numGPU=$1 
cppFiles=$(ls *.o)
pythonFiles=$(ls *.py)

for fileNm in ${cppFiles}

    do

    baseNm=$(basename "$fileNm" .o)
    resultDIR="groverResults"

    for repeat in {1..5}
    do
        for qubit in $(seq 10 5 20)
        do
            srun --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) ./$fileNm $qubit >> ${resultDIR}/${baseNm}_${numGPU}GPU
        done
    done

    for repeat in {1..5}
    do
        for qubit in $(seq 21 1 60)
        do
            srun --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) ./$fileNm $qubit >> ${resultDIR}/${baseNm}_${numGPU}GPU
        done
    done

done