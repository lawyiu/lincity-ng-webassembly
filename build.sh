#!/usr/bin/env bash
set -euo pipefail

# Get number of cores for setting number of jobs
CORES=$(grep processor /proc/cpuinfo | cut -d":" -f 2 | sort -nr | head -n1 | xargs)

if [ -z "$CORES" ]; then
    CORES=4
fi

# Build libxml2
if [ ! -f em_libs/lib/libxml2.a ]; then
    echo "Building libxml2"
    cd xml.js/libxml2
    NOCONFIGURE=1 ./autogen.sh
    cd ../
    mkdir -p ./build
    cd ./build
    emconfigure ../libxml2/configure --prefix="$(pwd)/../../em_libs" CFLAGS="-O3 -g" LDFLAGS="-s INITIAL_MEMORY=300MB -s ALLOW_MEMORY_GROWTH=1" \
    --with-http=no --with-ftp=no --with-python=no --with-threads=no --enable-shared=no
    emmake make install
    cd ../../
fi

# Build libphysfs
physfs_ver="physfs-3.0.2"

if [ ! -f em_libs/lib/libphysfs.a ]; then
    echo "Building $physfs_ver"

    if [ ! -d $physfs_ver ]; then
        wget -nc "https://www.icculus.org/physfs/downloads/$physfs_ver.tar.bz2"
        tar -xf $physfs_ver.tar.bz2
    fi

    cd $physfs_ver
    mkdir -p ./build
    cd ./build
    emcmake cmake -DCMAKE_INSTALL_PREFIX:PATH="$(pwd)/../../em_libs" -DCMAKE_C_FLAGS="-O3 -g" \
    -DPHYSFS_ARCHIVE_ZIP=off -DPHYSFS_ARCHIVE_7Z=off -DPHYSFS_ARCHIVE_GRP=off -DPHYSFS_ARCHIVE_WAD=off \
    -DPHYSFS_ARCHIVE_HOG=off -DPHYSFS_ARCHIVE_MVL=off -DPHYSFS_ARCHIVE_QPAK=off -DPHYSFS_ARCHIVE_SLB=off \
    -DPHYSFS_ARCHIVE_ISO9660=off -DPHYSFS_ARCHIVE_VDF=off -DPHYSFS_BUILD_SHARED=off ..
    emmake make install
    cd ../../
fi

# Build Lincity-ng
echo "Building Lincity-ng"
cd lincity-ng

if [ ! -f configure ]; then
    ./autogen.sh
fi

if [ ! -f config.status ]; then
    EM_PKG_CONFIG_PATH="../em_libs/lib/pkgconfig" emconfigure ./configure --prefix="$(pwd)/install/usr" --with-libphysfs="../em_libs/" \
    CFLAGS="-s USE_ZLIB=1 -s USE_SDL=2 -s USE_SDL_TTF=2 -s USE_SDL_MIXER=2 -s USE_SDL_GFX=2 -s USE_SDL_IMAGE=2" \
    LDFLAGS="-s USE_FREETYPE=1 -s USE_HARFBUZZ=1 -s LEGACY_GL_EMULATION=1 -s INITIAL_MEMORY=300MB -s ALLOW_MEMORY_GROWTH=1"
fi

echo "Building xmlgettext"
cd src/tools/xmlgettext
EMMAKEN_CFLAGS="-s USE_ZLIB=1" EMMAKEN_LDFLAGS="-s NODERAWFS=1" jam
cd ../../../

if ! grep '#!/usr/bin/env node' xmlgettext > /dev/null; then
    echo "#!/usr/bin/env node" > header
    cat xmlgettext >> header
    mv header xmlgettext
fi

chmod u+x xmlgettext

# Generate CREDITS so jam install doesn't error out
cat data/gui/creditslist.xml |grep -v "@"|cut -d\> -f2|cut -d\< -f1 >CREDITS
echo "# automatically generated from data/gui/creditslist.xml. Do not edit. #">>CREDITS

EMMAKEN_CFLAGS="-s SDL2_IMAGE_FORMATS=png -fexceptions -s DISABLE_EXCEPTION_CATCHING=0 -I ../em_libs/include" emmake jam -j"$CORES" install

emcc -O3 -g build/*/optimize/src/lincity-ng/*.o build/*/optimize/src/lincity/liblincity_lib.a build/*/optimize/src/PhysfsStream/libphysfsstream.a \
build/*/optimize/src/gui/liblincity_gui.a ../em_libs/lib/libxml2.a ../em_libs/lib/libphysfs.a build/*/optimize/src/tinygettext/libtinygettext.a \
-s ASYNCIFY -s USE_ZLIB=1 -s USE_SDL=2 -s USE_SDL_TTF=2 -s USE_SDL_MIXER=2 -s USE_SDL_IMAGE=2 -s USE_SDL_GFX=2 -s SDL2_IMAGE_FORMATS=png \
-s LEGACY_GL_EMULATION=1 -s INITIAL_MEMORY=300MB -s ALLOW_MEMORY_GROWTH=1 -fexceptions -s DISABLE_EXCEPTION_CATCHING=0 --shell-file ../shell.html \
-o index.html --use-preload-cache --preload-file install/usr/share/lincity-ng@/data

mkdir -p dist
cp -u index.{html,js,wasm,data} dist/
