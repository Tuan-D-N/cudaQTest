codeDir="../codeFiles"
dataDir="../dataFiles"
statDir="../statsFile"
runTimeData="../runtimeData"


rm ${dataDir}/*.sqlite ${dataDir}/*.nsys-rep

executables=(
    "cuQuantumMalloc"
    "cudaQ"
    "cuQuantumManagedNoPrefetch"
    "cuQuantumManagedWithPrefetch"
)

# Loop through the executables
for exe in "${executables[@]}"; do
    # Profile the executable
    nsys profile --output=${dataDir}/${exe} --force-overwrite true ${dataDir}/${exe}.o

    # Remove any leftover SQLite files
    rm ${dataDir}/*.sqlite

    # Generate stats
    nsys stats ${dataDir}/${exe}.nsys-rep > ${statDir}/${exe}.stats
done