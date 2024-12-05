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


targets=(density-matrix-cpu ionq iqm nvidia-fp64 nvidia-mqpu-fp64 nvidia-mqpu-mps nvidia-mqpu nvidia nvqc oqc orca photonics qpp-cpu quantinuum remote-mqpu tensornet-mps tensornet) 

for target in targets
do
    



  # Loop through each .cpp file
  for file in $CPP_FILES; do
    # Get the filename without the extension
    BASENAME=$(basename "$file" .cpp).o
    
    # Compile the .cpp file into an executable
    echo "Compiling $file..."
    $CXX $CXXFLAGS "$file" -o "${BASENAME}_${target}" --target=${target}
    
    # Check if compilation succeeded
    if [ $? -eq 0 ]; then
      echo "Compilation successful: $BASENAME"
    else
      echo "Compilation failed for: $file"
      exit 1
    fi
  done

done

echo "All files compiled successfully."
