Produce documentation for [Fluid Corpus Manipulation Library](https://github.com/flucoma/flucoma-core) objects, from a combination of handwritten material and generated data. 

## Overview 
The generated data comes from building an running a set of C++ executables that produce JSON files detailing the interface of FluCoMa objects (parameter and message names, etc.). 

The handwritten documentation is in reStructuredText files that are meant to match up with the generated data. Some Python code then makes sure this assumption is true (i.e. validates the completeness of the handwritten docs against the generated data), and produces rendered documentation for a choice of environments (Max, Pure Data, Supercollider and the command line). 

This is intended principally as internal tooling, so there may well be rough edges and weird things. Operation on platforms other than Mac OS or Linux is untested. 

## Quick Start 

The routine way to interact with everything is via CMake. In addition to this you will need: git, a working C++ toolchain, and Python >= 3.8 with the packages listed in `requirements.txt`. (use `pip install -r requirements.txt` to install all these in one go. )

To configure the project and generate the JSON run
```bash
mkdir build
cd build
cmake ..
make
```

If you have a local checkout of the `flucoma-core` repo, then this can be used by adding `-DFLUID_PATH=<path to your flucoma core>`. 

The JSON files are generated into `build/json`.

The CMake exposes targets for producing docs for particular environments (`MAKE_MAX_REF`, `MAKE_PD_REF`, `MAKE_SC_REF`,`MAKE_CLI_REF`). These targets will (re-)generate the JSON if needed and then run a Python script to produce the actual docs. 

The output paths for the docs default to `build/<host>_ref` but can be overridden by setting CMake cache variables (`MAX_DOC_OUT`,`PD_DOC_OUT`,`CLI_DOC_OUT`,`SC_DOC_OUT`)

### Python Herding
On platforms with multiple Pythons installed (like Macs), CMake can sometimes need some heavy hints in order to avoid settling on system Python. If you get error messages about missing packages, it is likely that CMake has found the 'wrong' one. 

For recent versions of CMake (>= 3.15?), adding `-DPYTHON_EXECUTABLE=<path to your python of choice>` is a blunt instrument, but normally works. You can find the path via `which python` in the terminal, if needed. Considerably more options can be found in the [documentation for CMake's `find_python` module](https://cmake.org/cmake/help/latest/module/FindPython.html). 

## Documentation 

Is still thin, but will gather mass in the `code-docs` directory. 

## Credits 
#### FluCoMa core development team (in alphabetical order)
Owen Green, Gerard Roma, Pierre Alexandre Tremblay

#### Other contributors (in alphabetical order):
James Bradbury, Francesco Cameli, Alex Harker, Ted Moore

> This project has received funding from the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation programme (grant agreement No 725899).
