# LinCity-NG to Webassembly
[![Azure Static Web Apps CI/CD](https://github.com/lawyiu/lincity-ng-webassembly/actions/workflows/azure-static-web-apps-ambitious-rock-07651161e.yml/badge.svg)](https://github.com/lawyiu/lincity-ng-webassembly/actions/workflows/azure-static-web-apps-ambitious-rock-07651161e.yml)

This repository contains a build script to compile LinCity-NG for the web using Emscripten.

Try out the game [here](https://ambitious-rock-07651161e.azurestaticapps.net/).

## Build Instructions (Windows, macOS, Linux)
Note that building on Windows will require using WSL 2 (Using Docker or without) or WSL 1 (Without Docker).

### Using Docker (Recommended)
1. `git clone --recursive https://github.com/lawyiu/lincity-ng-webassembly.git`
2. `cd lincity-ng-webassembly`
3. `docker pull emscripten/emsdk:latest`
4. `docker build -t lincity-ng:latest ./docker`
5. `docker run -p8080:8080 lincity-ng:latest `
6. Open a web browser and go to `http://localhost:8080`

### Without Docker (Not recommended since installing dependencies differs depending on build platform)
1. Install [Emscripten](https://emscripten.org/docs/getting_started/downloads.html)
2. Install autoconf, automake, libtool, pkg-config, and jam using your platform's package manager (apt, brew, pacman, etc)
3. `git clone --recursive https://github.com/lawyiu/lincity-ng-webassembly.git`
4. `cd lincity-ng-webassembly`
5. `./build.sh`
6. `cd lincity-ng`
7. `emrun --no_browser --port=8080 index.html`
8. Open a web browser and go to `http://localhost:8080`

## Current Limitations
* Save files are lost if the user closes the browser tab.
* Save files downloading and uploading to/from a local folder is not implemented yet.
* Performance in the browser is slow (low framerate).
