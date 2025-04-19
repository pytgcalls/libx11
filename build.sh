source /dev/stdin <<< "$(curl -s https://raw.githubusercontent.com/pytgcalls/build-toolkit/refs/heads/master/build-toolkit.sh)"

import libraries.properties

build_and_install "macros" configure
build_and_install "libXtrans" configure
build_and_install "xorgproto" configure
build_and_install "libXfixes" configure-static
build_and_install "libXi" configure-static
build_and_install "xcbproto" configure

build_and_install "libXau" configure-static
build_and_install "libXcb" configure-static
build_and_install "libX11" configure-static
build_and_install "libXcomposite" configure-static
build_and_install "libXdamage" configure-static
build_and_install "libXext" configure-static
build_and_install "libXrender" configure-static
build_and_install "libXrandr" configure-static
build_and_install "libXtst" configure-static

copy_libs "libXau" "artifacts"
copy_libs "libXcb" "artifacts"
copy_libs "libX11" "artifacts"
copy_libs "libXcomposite" "artifacts"
copy_libs "libXdamage" "artifacts"
copy_libs "libXext" "artifacts"
copy_libs "libXfixes" "artifacts"
copy_libs "libXrender" "artifacts"
copy_libs "libXrandr" "artifacts"
copy_libs "libXtst" "artifacts"