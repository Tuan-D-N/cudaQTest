#!/bin/bash

# Set the compiler and flags
CXX="nvq++"
CXXFLAGS=""

# Find all .cpp files in the current directory
CPP_FILES=$(ls *.cpp)

# Check if there are any .cpp files
if [ -z "$CPP_FILES" ]; then
  echo "No .cpp files found in the current directory."
  exit 1
fi

# failed ionq iqm oqc orca quantinuum
targets=(density-matrix-cpu nvidia-fp64 nvidia-mqpu-fp64 nvidia-mqpu-mps nvidia-mqpu nvidia nvqc photonics qpp-cpu remote-mqpu tensornet-mps tensornet) 

for target in ${targets[@]}
do
    



  # Loop through each .cpp file
  for file in $CPP_FILES; do
    # Get the filename without the extension
    BASENAME=$(basename "$file" .cpp)
    newName=${BASENAME}_${target}.o
    
    # Compile the .cpp file into an executable
    echo "Compiling $file... for target = ${target}"
    $CXX $CXXFLAGS "$file" -o "$newName" --target=${target} >> compile.log
    
    # Check if compilation succeeded
    if [ $? -eq 0 ]; then
      echo "Compilation successful: $newName"
    else
      echo "Compilation failed for: $file"
      break
    fi
  done

done

echo "All files compiled successfully."
