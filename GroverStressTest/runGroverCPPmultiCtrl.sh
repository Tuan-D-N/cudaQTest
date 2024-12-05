#!/bin/bash --login

#SBATCH --exclusive   
#SBATCH --gres=gpu:1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32

for repeat in {1..5}
do
    for qubit in $(seq 2 2 40)
    do
        srun --exclusive --gres=gpu:1 --ntasks=1 --cpus-per-task=32 ./GroverScalingTest_multiCtrl_functors.o $qubit > groverResults/GroverScalingTest_multiCtrl_functors_qubit${qubit}_repeat${repeat}
    done
done

