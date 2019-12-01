#include <clients/nrt/StandardizeClient.hpp>
#include <FluidParameterDump.hpp>
int main(int argc, char *argv[]) {
  using namespace fluid::client;
  if (!argc) std::cerr << "Please pass a folder to write to";
  std::cout << "Write JSON to " << argv[1];
  ParameterDump<NRTThreadedStandardizeClient>::dump("Normalize", argv[1]);
  return 0;
}
