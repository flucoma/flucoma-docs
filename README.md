Generate JSON files of parameters from [Fluid Corpus Manipulation Library](https://github.com/flucoma/flucoma-core) objects

This is quick and dirty, so don't be surprised at weirdness.

The JSON will turn up in a folder called `json` in the top level directory, and is generated as part of compilation (by CMake).

So, simple build steps should be along the lines of
```bash
mkdir build
cd build
cmake -DFLUID_PATH=/your/path/to/your/fluid-corpus-manipulation/repo ..
make
```

This requires python 3 with the docutils, jinja2, and pyYAML (>=5.1)  packages. 

If you have multiple python 3s on your system, using variables like CMAKE_FIND_FRAMEWORK might help CMake find the right one. 


# Credits 
### FluCoMa core development team (in alphabetical order)
Owen Green 
Gerard Roma
Pierre Alexandre Tremblay

### Other contributors:
Alex Harker, Francesco Cameli

> This project has received funding from the European Research Council (ERC) under the European Union’s Horizon 2020 research and innovation programme (grant agreement No 725899).
