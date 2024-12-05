
numGPU=$1




sbatch --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) --time=10:00:00 runPynGPU.sh ${numGPU} 
