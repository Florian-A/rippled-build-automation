# Builder Rippled

This repository provides a Dockerized and automated solution for compiling the Rippled daemon.

It builds a Docker image containing all the necessary prerequisites for compilation, fetches the project sources from GitHub, and then performs the compilation.

### Prerequisites

- Docker
- Make
- A processor with the same architecture as the target

### Targets 

- ubuntu-22-04_x86

### Usage 

To initiate the compilation, run the command make followed by the target name. For example:


```
make ubuntu-22-04_x86
```

Once the compilation is complete, the compiled binary will be located in the `build` directory.

Here’s the translation:

**Please note that the compilation may take over an hour to complete!**

### Acknowledgments

Some scripts have been modified from those found at https://github.com/thejohnfreeman/rippled-docker. A big thank you for their contribution!
