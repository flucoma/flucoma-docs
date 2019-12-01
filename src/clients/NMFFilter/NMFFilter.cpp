#include <clients/rt/NMFFilter.hpp>
#include <FluidParameterDump.hpp>
int main(int argc, char *argv[]) {
  using namespace fluid::client;
  if (!argc) std::cerr << "Please pass a folder to write to";
  std::cout << "Write JSON to " << argv[1]; 
  ParameterDump<RTNMFFilterClient>::dump("NMFFilter", argv[1]);
  return 0;
}
