FROM emscripten/emsdk:3.1.24

RUN apt-get update && apt-get install -y nano vim-tiny tmux automake libtool pkg-config jam
RUN chown emscripten:emscripten /src

USER emscripten
RUN git clone https://github.com/lawyiu/lincity-ng-webassembly

WORKDIR lincity-ng-webassembly
ARG branch_name=main
RUN git checkout ${branch_name}
RUN git submodule update --init --recursive
RUN ./build.sh

WORKDIR lincity-ng
CMD [ "emrun", "--no_browser", "--port=8080", "index.html" ]
