mkdir -p build
cd build
cmake ..
echo "Building c libs finished..."
cd ..
c3c build
echo "Built c3 project"

