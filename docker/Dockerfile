FROM emscripten/emsdk:2.0.28

RUN apt-get update && apt-get install -y nano vim-tiny tmux automake libtool pkg-config jam
RUN chown emscripten:emscripten /src

USER emscripten
RUN git clone --recursive https://github.com/lawyiu/lincity-ng-webassembly

WORKDIR lincity-ng-webassembly
RUN ./build.sh

WORKDIR lincity-ng
CMD [ "emrun", "--no_browser", "--port=8080", "index.html" ]
