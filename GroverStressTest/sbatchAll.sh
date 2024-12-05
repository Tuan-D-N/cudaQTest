
numGPU=$1
cppFiles=$(ls *.o)
pythonFiles=$(ls *.py)

for file in ${cppFiles}
do
    sbatch runCPPnGPU.sh file ${numGPU} --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU))
done

for file in ${pythonFiles}
do
    sbatch runPynGPU.sh file ${numGPU} --exclusive --gres=gpu:${numGPU} --ntasks=${numGPU} --cpus-per-task=$((32 * numGPU))
done