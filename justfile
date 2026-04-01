build:
    #!/usr/bin/env bash
    source .venv/bin/activate
    cmake -B build -G Ninja -DARCH=arm64 -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=1
    cmake --build build

install:
    cmake --install build

reload: build install
    pkill TaigiTelex || true
