export ACLOCAL_PATH=/usr/share/aclocal
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:$PKG_CONFIG_PATH

LIBRARIES_FILE="libraries.properties"

get_version() {
    grep "^$1=" "$LIBRARIES_FILE" | cut -d '=' -f2
}

UTIL_MACROS_VERSION=$(get_version "util-macros")
XTRANS_VERSION=$(get_version "Xtrans")
XI_VERSION=$(get_version "Xi")

# Install util-macros
git clone https://gitlab.com/freedesktop-sdk/mirrors/freedesktop/xorg/util/macros.git --branch util-macros-$UTIL_MACROS_VERSION --depth 1
cd macros
echo 'Running autogen.sh for macros...'
./autogen.sh --prefix=/usr;
if [ $? -ne 0 ]; then
  echo 'Error while executing autogen.sh for macros' >&2
  exit 1
fi
make -j$(nproc)
if [ $? -ne 0 ]; then
  echo 'Error while executing make for macros' >&2
  exit 1
fi
make install
if [ $? -ne 0 ]; then
  echo 'Error while executing make install for macros' >&2
  exit 1
fi
cd ..

# Install libXtrans
git clone https://gitlab.com/freedesktop-sdk/mirrors/freedesktop/xorg/lib/libxtrans.git --branch xtrans-$XTRANS_VERSION --depth 1
cd libxtrans
echo 'Running autogen.sh for libxtrans...'
./autogen.sh --prefix=/usr;
if [ $? -ne 0 ]; then
  echo 'Error while executing autogen.sh for libxtrans' >&2
  exit 1
fi
make -j$(nproc)
if [ $? -ne 0 ]; then
  echo 'Error while executing make for libxtrans' >&2
  exit 1
fi
make install
if [ $? -ne 0 ]; then
  echo 'Error while executing make install for libxtrans' >&2
  exit 1
fi
cd ..

# Install xorgproto
git clone https://gitlab.com/freedesktop-sdk/mirrors/freedesktop/xorg/proto/xorgproto.git --branch xorgproto-2024.1 --depth 1
cd xorgproto
echo 'Running autogen.sh for xorgproto...'
./autogen.sh --prefix=/usr;
if [ $? -ne 0 ]; then
  echo 'Error while executing autogen.sh for xorgproto' >&2
  exit 1
fi
make -j$(nproc)
if [ $? -ne 0 ]; then
  echo 'Error while executing make for xorgproto' >&2
  exit 1
fi
make install
if [ $? -ne 0 ]; then
  echo 'Error while executing make install for xorgproto' >&2
  exit 1
fi
cd ..

# Install libXi
git clone https://gitlab.com/freedesktop-sdk/mirrors/freedesktop/xorg/lib/libXi.git --branch libXi-$XI_VERSION --depth 1
cd libXi
echo 'Running autogen.sh for libXi...'
./autogen.sh --prefix=/usr;
if [ $? -ne 0 ]; then
  echo 'Error while executing autogen.sh for libXi' >&2
  exit 1
fi
make -j$(nproc)
if [ $? -ne 0 ]; then
  echo 'Error while executing make for libXi' >&2
  exit 1
fi
make install
if [ $? -ne 0 ]; then
  echo 'Error while executing make install for libXi' >&2
  exit 1
fi
cd ..

mkdir -p artifacts/lib
mkdir -p artifacts/include

# Install other libraries
while IFS='=' read -r lib version; do
  echo 'Processing lib'${lib}'...'
  if [[ -n "$lib" && ! "$lib" =~ ^# ]]; then
    if [[ "$lib" == "Xi" || "$lib" == "Xtrans" || "$lib" == "xorgproto" || "$lib" == "util-macros" ]]; then
      continue
    fi
    echo 'Cloning lib'${lib}'...'
    git clone 'https://gitlab.com/freedesktop-sdk/mirrors/freedesktop/xorg/lib/lib'${lib}'.git' --branch 'lib'${lib}'-'$version --depth 1
    cd 'lib'${lib}
    echo 'Running autogen.sh for lib'${lib}'...'
    ./autogen.sh --enable-static --prefix=/app/lib${lib}/build;
    if [ $? -ne 0 ]; then
      echo 'Error while executing autogen.sh for lib'${lib} >&2
      exit 1
    fi
    make -j$(nproc)
    if [ $? -ne 0 ]; then
      echo 'Error while executing make for lib'${lib} >&2
      exit 1
    fi
    make install
    if [ $? -ne 0 ]; then
      echo 'Error while executing make install for lib'${lib} >&2
      exit 1
    fi
    echo 'Copying lib'${lib}' to artifacts/lib...'
    cp -r build/lib/*.a ../artifacts/lib/
    for dir in build/include/*/; do
      cp -r "$dir" ../artifacts/include/
    done
    cd ..
  fi
done < $LIBRARIES_FILE
echo 'All libraries installed successfully.'