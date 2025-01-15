codeDir="../codeFiles"
dataDir="../dataFiles"
statDir="../statsFile"
runTimeData="../runtimeData"

nvc++ ${codeDir}/cuQuantumMalloc.cu -lcustatevec -o ${dataDir}/cuQuantumMalloc.o -gpu=mem:unified
nvc++ ${codeDir}/cuQuantumManagedNoPrefetch.cu -lcustatevec -o ${dataDir}/cuQuantumManagedNoPrefetch.o -gpu=mem:unified
nvc++ ${codeDir}/cuQuantumManagedWithPrefetch.cu -lcustatevec -o ${dataDir}/cuQuantumManagedWithPrefetch.o -gpu=mem:unified
nvq++ ${codeDir}/cudaQ.cpp -o ${dataDir}/cudaQ.o

