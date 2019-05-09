
for a in  ~/fluid_supercollider/src/*;
do
  client=${a##/*Fluid};
  rm ${client}/${client}.cpp; touch ${client}/${client}.cpp;
  src=${client}/${client}.cpp;
  sc_src=${a}/${a##/*/src/}.cpp;
  cat $sc_src | grep -e \#include\ \<clients/ >> $src;
  makestr=`cat $sc_src | grep -e makeSCWrapper`;
  makestr_beg=${makestr##*make*\<}
  templ=${makestr_beg%\>*}
  echo "#include <FluidParameterDump.hpp>" >> $src;
  echo "int main(int argc, char *argv[]) {" >> $src;
  echo "  using namespace fluid::client;" >> $src;
  echo "  if (!argc) std::cerr << \"Please pass a folder to write to\";" >> $src;
  echo "  std::cout << \"Write JSON to \" << argv[1]; " >> $src ;
  echo "  ParameterDump<${templ}>::dump(\"${client}\", argv[1]);" >> $src;
  echo "  return 0;" >> $src;
  echo "}" >> $src;
done
