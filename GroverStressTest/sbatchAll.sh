
numGPU=$1



sbatch runCPPnGPU.sh ${numGPU} --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU))



sbatch runPynGPU.sh ${numGPU} --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU))
