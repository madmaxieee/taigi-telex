# Tâi-gí Telex

Tâi-gí Telex is a Taiwanese Tâi-lô input method with Telex-style tone keys for macOS.

**Live Demo:** https://telex.kahiok.com

## User Guide

### Download

[Download Latest](https://github.com/madmaxieee/taigi-telex/releases/tag/latest)

### Basic Rules

Type letters normally. Special keys modify the output:

| Key | Output | Usage                         |
| --- | ------ | ----------------------------- |
| `c` | `ts`   | Use `c` to type `ts`          |
| `C` | `Ts`   | Capital `C` for capital `Ts`  |
| `z` | `tsh`  | Use `z` to type `tsh`         |
| `Z` | `Tsh`  | Capital `Z` for capital `Tsh` |
| `f` | `-`    | Use `f` to type a hyphen      |

### Tone Marks

Add tone marks by typing the corresponding key at the end of a syllable:

| Key | Tone | Example    |
| --- | ---- | ---------- |
| `v` | 2nd  | `av` → `á` |
| `y` | 3rd  | `ay` → `à` |
| `d` | 5th  | `ad` → `â` |
| `w` | 7th  | `aw` → `ā` |
| `x` | 8th  | `ax` → `a̍` |
| `q` | 9th  | `aq` → `a̋` |

### Examples

| Input                | Output   | Notes                                  |
| -------------------- | -------- | -------------------------------------- |
| `te` + `v`           | `té`     | Second tone                            |
| `khoo` + `y`         | `khòo`   | Third tone                             |
| `lang` + `d`         | `lâng`   | Fifth tone                             |
| `kang` + `w`         | `kāng`   | Seventh tone                           |
| `tit` + `x`          | `ti̍t`    | Eighth tone                            |
| `cang` + `q`         | `tsa̋ng`  | Ninth tone (and consonant replacement) |
| `c`                  | `ts`     | Consonant replacement (s)              |
| `z`                  | `tsh`    | Consonant replacement (z)              |
| `taid` + `f` + `giv` | `tâi-gí` | Hyphen shorthand (f)                   |

### Tone Mark Placement

Tone marks are automatically placed on the correct vowel:

- **Priority order**: `a` > `e` > `o` > `u` > `i`
- **Exceptions**:
  - `iu` → mark on `u` (e.g., `liuv` → `liú`)
  - `ui` → mark on `i` (e.g., `huiy` → `hùi`)
- `ng` and `m` can also be vowels when no other vowels are around.

### Tips

- Press the **same tone key twice** to type the letter itself (e.g., `avv` → `av`)
- Press the **same consonant key twice** to type it literally (e.g., `zz` → `z`, `cc` → `c`)
- Non-letter characters (space, comma, period, numbers) automatically commit the current composition
- Press return key to commit current buffer
- Caps lock to switch between Tâi-gí Telex and English works, like any Chinese input method

## Contribution Guide

### Install dependencies

```sh
brew install cmake ninja
pip install "dmgbuild[badge_icons]"
# or if you use mise
mise i
```

### Build

```sh
cmake -B build -G Ninja \
  -DARCH=arm64 \
  -DCMAKE_BUILD_TYPE=Release
cmake --build build
# or if you use mise
mise run build
```

### Install

Either open `build/TaigiTelex.dmg` (if prompted with a "TaigiTelex is in use" error, execute `pkill TaigiTelex` and retry), or

```sh
cmake --install build
# or if you use mise
mise run install
```

- On first time installation, log out and log back in, then in `System Settings` -> `Keyboard` -> `Input Sources` (Edit), add `taigi-telex` from `Chinese, Traditional`.
- On further installations, switch to another input method, `pkill TaigiTelex`, then switch back.

## Acknowledgement

- [toyimk](https://github.com/eagleoflqj/toyimk) Thanks toyimk for the build system setup
- [macSKK](https://github.com/mtgto/macSKK) Thanks macSKK for architecture reference
