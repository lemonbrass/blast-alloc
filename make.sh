mkdir -p build
cd build
cmake ..
echo "Building c libs.."
make
echo "Built c libs"
cd ..
c3c build
echo "Built c3 project"

