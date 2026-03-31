build:
    cmake -B build -G Ninja -DARCH=arm64 -DCMAKE_BUILD_TYPE=Release
    cmake --build build

install:
    cmake --install build

reload: build install
    pkill Toyimk || true
