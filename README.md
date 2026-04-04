# Tâi-gí Telex

Tâi-gí Telex is a Taiwanese input method with Telex-style tone keys for macOS. It supports both **Tâi-lô (TL)** and **Pe̍h-ōe-jī (POJ)** romanization systems.

**Live Demo:** https://telex.kahiok.com

## Input Modes

The input method provides two modes that you can switch between using **Caps Lock** or by selecting from the input menu:

| Mode                | Description                                 |
| ------------------- | ------------------------------------------- |
| **TL (Tâi-lô)**     | Modern standard romanization used in Taiwan |
| **POJ (Pe̍h-ōe-jī)** | Classic missionary romanization system      |

Both modes share the same tone marking keys. The main differences are in consonant mappings and POJ-specific vowel features.

## User Guide

### Download

[Download Latest](https://github.com/madmaxieee/taigi-telex/releases/tag/latest)

### Basic Rules

Type letters normally. Special keys modify the output:

#### Consonant Mappings

| Key | TL Output | POJ Output | Usage                                       |
| --- | --------- | ---------- | ------------------------------------------- |
| `c` | `ts`      | `chh`      | TL: `ts` / POJ: `chh` aspirated affricate   |
| `C` | `Ts`      | `Chh`      | Capital form                                |
| `z` | `tsh`     | `ch`       | TL: `tsh` / POJ: `ch` unaspirated affricate |
| `Z` | `Tsh`     | `Ch`       | Capital form                                |
| `f` | `-`       | `-`        | Hyphen shorthand (both modes)               |

#### POJ-Specific Features

When using **POJ mode**, you can type:

| Input | Output | Description                     |
| ----- | ------ | ------------------------------- |
| `nn`  | `ⁿ`    | Nasalization (superscript n)    |
| `NN`  | `ⁿ`    | Capital input also works        |
| `oo`  | `o͘`    | POJ-specific vowel (o with dot) |
| `OO`  | `O͘`    | Capital form                    |

To type literal `nn` or `oo`, press the key **three times** (e.g., `nnn` → `nn`, `ooo` → `oo`).

### Tone Marks

Add tone marks by typing the corresponding key at the end of a syllable (same in both modes):

| Key | Tone | Example    |
| --- | ---- | ---------- |
| `v` | 2nd  | `av` → `á` |
| `y` | 3rd  | `ay` → `à` |
| `d` | 5th  | `ad` → `â` |
| `w` | 7th  | `aw` → `ā` |
| `x` | 8th  | `ax` → `a̍` |
| `q` | 9th  | `aq` → `a̋` |

### Examples

#### Tâi-lô (TL) Mode

| Input                | Output   | Notes                      |
| -------------------- | -------- | -------------------------- |
| `te` + `v`           | `té`     | Second tone                |
| `khoo` + `y`         | `khòo`   | Third tone                 |
| `lang` + `d`         | `lâng`   | Fifth tone                 |
| `kang` + `w`         | `kāng`   | Seventh tone               |
| `tit` + `x`          | `ti̍t`    | Eighth tone                |
| `cang` + `q`         | `tsáng`  | Ninth tone (consonant: ts) |
| `c`                  | `ts`     | Consonant replacement      |
| `z`                  | `tsh`    | Consonant replacement      |
| `taid` + `f` + `giv` | `tâi-gí` | Hyphen shorthand (f)       |

#### POJ Mode

| Input               | Output   | Notes                         |
| ------------------- | -------- | ----------------------------- |
| `cheng` + `v`       | `chhéng` | Second tone (consonant: chh)  |
| `choan` + `y`       | `chhòan` | Third tone                    |
| `cheng` + `d`       | `chêng`  | Fifth tone (consonant: ch)    |
| `chng` + `w`        | `chnḡ`   | Seventh tone on syllabic ng   |
| `sio` + `x`         | `sio̍h`   | Eighth tone                   |
| `onn` + `y`         | `òⁿ`     | Nasal vowel with tone         |
| `poo` + `d`         | `pô͘`     | POJ oo vowel with tone        |
| `ann`               | `aⁿ`     | Nasalization (nn → ⁿ)         |
| `onnf` + `ji` + `v` | `òⁿ-jí`  | Hyphen with nasal vowel       |
| `annn`              | `ann`    | Escape: triple n → literal nn |

### Tone Mark Placement

Tone marks are automatically placed on the correct vowel:

**Tâi-lô (TL) priority order**: `a` > `e` > `o` > `u` > `i`

- **Exceptions**:
  - `iu` → mark on `u` (e.g., `liuv` → `liú`)
  - `ui` → mark on `i` (e.g., `huiy` → `hùi`)

**POJ priority order**: `o͘` > `a` > `e` > `o` > `u` > `i`

- **Exceptions**:
  - `eo` → mark on `e` (e.g., `heov` → `hé` + `o`)
  - `oe` → mark on `o` (e.g., `hoey` → `hòe`)

Both modes support `ng` and `m` as vowels when no other vowels are present.

### Tips

- Press the **same tone key twice** to type the letter itself (e.g., `avv` → `av`)
- Press the **same consonant key twice** to type it literally (e.g., `zz` → `z`, `cc` → `c`)
- In **POJ mode**, press a **double vowel key three times** to escape (e.g., `nnn` → `nn`, `ooo` → `oo`)
- Non-letter characters (space, comma, period, numbers) automatically commit the current composition
- Press return key to commit current buffer
- Use **Caps Lock** to switch between Tâi-gí Telex modes and English, like any Chinese input method

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

- On first time installation, log out and log back in, then in `System Settings` -> `Keyboard` -> `Input Sources` (Edit), `Tâi-gí Telex` from `Chinese, Traditional`.
- On further installations, switch to another input method, `pkill TaigiTelex`, then switch back.

## Acknowledgement

- [toyimk](https://github.com/eagleoflqj/toyimk) Thanks toyimk for the build system setup
- [macSKK](https://github.com/mtgto/macSKK) Thanks macSKK for architecture reference
