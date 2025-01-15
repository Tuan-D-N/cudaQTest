codeDir="../codeFiles"
dataDir="../dataFiles"
statDir="../statsFile"
runTimeData="../runtimeData"

executables=(
    "cuQuantumMalloc"
    "cudaQ"
    "cuQuantumManagedNoPrefetch"
    "cuQuantumManagedWithPrefetch"
)

# Loop through the executables
for exe in "${executables[@]}"; do
    ${dataDir}/${exe}.o
done