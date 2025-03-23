# shellcheck disable=SC1090
source <(curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh)

UTIL_MACROS_VERSION=$(get_version "util-macros")
XTRANS_VERSION=$(get_version "Xtrans")
XI_VERSION=$(get_version "Xi")
XORGPROTO_VERSION=$(get_version "xorgproto")
XCBPROTO_VERSION=$(get_version "xcb")

build_and_install "${FREEDESKTOP_GIT}xorg/util/macros.git" "util-macros-$UTIL_MACROS_VERSION" autogen
build_and_install "${FREEDESKTOP_GIT}xorg/lib/libxtrans.git" "xtrans-$XTRANS_VERSION" autogen
build_and_install "${FREEDESKTOP_GIT}xorg/proto/xorgproto.git" "xorgproto-$XORGPROTO_VERSION" autogen
build_and_install "${FREEDESKTOP_GIT}xorg/proto/xcbproto.git" "xcb-proto-$XCBPROTO_VERSION" autogen
build_and_install "${FREEDESKTOP_GIT}xorg/lib/libXi.git" "libXi-$XI_VERSION" autogen-static --prefix=/usr

run mkdir -p artifacts/lib
run mkdir -p artifacts/include

while IFS='=' read -r lib version; do
  echo "Processing lib${lib}..."
  if [[ -n "$lib" && ! "$lib" =~ ^# ]]; then
    if [[ "$lib" == "Xi" || "$lib" == "Xtrans" || "$lib" == "xorgproto" || "$lib" == "util-macros" ]]; then
      continue
    fi
    echo "Cloning lib${lib}..."
    build_and_install "${FREEDESKTOP_GIT}xorg/lib/lib${lib}.git" "lib${lib}-$version" autogen-static --prefix="$(pwd)/lib${lib}/build"
    echo "Copying lib${lib} to artifacts/lib..."
    run cp -r lib"${lib}"/build/lib/*.a artifacts/lib/
    for dir in "lib${lib}"/build/include/*/; do
      run cp -r "$dir" artifacts/include/
    done
  fi
done < "$LIBRARIES_FILE"
echo "All libraries successfully built"