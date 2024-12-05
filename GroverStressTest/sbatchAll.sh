
numGPU=$1



sbatch runCPPnGPU.sh ${numGPU} --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) --time=10:00:00



sbatch runPynGPU.sh ${numGPU} --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU)) --time=10:00:00
