# taigi-telex

## Install dependencies

```sh
brew install swiftlint ninja
pip install "dmgbuild[badge_icons]"
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

- On first time installation,
  logout your account and login,
  then in `System Settings` -> `Keyboard` -> `Input Sources`,
  add `taigi-telex` from `Min nan Chinese`.
- On further installations,
  switch to another input method,
  `pkill TaigiTelex`,
  then switch back.
