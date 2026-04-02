# taigi-telex

## Install dependencies

```sh
brew install cmake ninja
pip install "dmgbuild[badge_icons]"
# or if you use mise
mise i
```

## Build

```sh
cmake -B build -G Ninja \
  -DARCH=arm64 \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build
# or if you use mise
mise run build
```

## Install

Either open `build/TaigiTelex.dmg`
(if prompted taigi-telex is in use error,
execute `pkill TaigiTelex` and retry), or

```sh
cmake --install build
# or if you use just
mise run install
```

- On first time installation, logout and log back in, then in `System Settings` -> `Keyboard` -> `Input Sources` (Edit), add `taigi-telex` from `Chinese, Traditional`.
- On further installations, switch to another input method, `pkill TaigiTelex`, then switch back.
