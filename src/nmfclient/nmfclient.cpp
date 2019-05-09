#include <FluidParameterDump.hpp>
#include <clients/rt/HPSSClient.hpp>
#include <unistd.h> //getcwd

int main(int argc, char *argv[]) {
  using namespace fluid::client;
  
  if (!argc) std::cerr << "Please pass a folder to write to";
  
  ParameterDump<HPSSClient>::dump("HPSS", argv[0]);
  return 0;
}

