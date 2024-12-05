#!/bin/bash --login

#SBATCH --exclusive   
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32

for repeat in {1..5}
do
    for qubit in $(seq 10 5 60)
    do
        srun --exclusive --gres=gpu:1 --ntasks=1 --cpus-per-task=32 python3 GroverScalingTest.py $qubit >> groverResults/GroverScalingTest_qubit${qubit}
    done
done

