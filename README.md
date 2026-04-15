# Tâi-gí Telex

Tâi-gí Telex is a Taiwanese input method with Telex-style tone keys for macOS. It supports both **Tâi-lô (TL)** and **Pe̍h-ōe-jī (POJ)** romanization systems.

**Live Demo:** https://telex.kahiok.com

## User Guide

### Download & Install

[Download Latest](https://github.com/madmaxieee/taigi-telex/releases/tag/latest)

1. Download the `TaigiTelex-x.x.x.pkg` file
2. Double-click the PKG file to run the installer
3. Click through the welcome screen and install

**Important - Unsigned Package Warning:**

This package is not signed with an Apple Developer certificate. On first install, you may see a warning saying the package "cannot be opened because it is from an unidentified developer." To proceed:

1. Open **System Settings** → **Privacy & Security**
2. Scroll down to the "Security" section
3. Click **Open Anyway** next to the message about TaigiTelex
4. Confirm when prompted

After installation:

- Go to **System Settings** → **Keyboard** → **Input Sources** (Edit)
- Click the **+** button and select **Tâi-gí Telex** from **Chinese, Traditional**
- If the input method doesn't appear, log out and log back in

### Basic Rules

Type letters normally. Special keys modify the output:

#### Consonant Mappings

| Key | TL Output | POJ Output | Usage                                       |
| --- | --------- | ---------- | ------------------------------------------- |
| `c` | `tsh`     | `chh`      | TL: `ts` / POJ: `chh` aspirated affricate   |
| `C` | `Tsh`     | `Chh`      | Capital form                                |
| `z` | `ts`      | `ch`       | TL: `tsh` / POJ: `ch` unaspirated affricate |
| `Z` | `Ts`      | `Ch`       | Capital form                                |
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
| `zang` + `q`         | `tsáng`  | Ninth tone (consonant: ts) |
| `z`                  | `ts`     | Consonant replacement      |
| `c`                  | `tsh`    | Consonant replacement      |
| `taid` + `f` + `giv` | `tâi-gí` | Hyphen shorthand (f)       |

#### POJ Mode

| Input                | Output   | Notes                                     |
| -------------------- | -------- | ----------------------------------------- |
| `hoo` + `v`          | `hó͘`     | Second tone (with long o vowel)           |
| `pa` + `y`           | `pà`     | Third tone                                |
| `kau` + `d`          | `kâu`    | Fifth tone                                |
| `ciunn` + `w`        | `chhiūⁿ` | Seventh tone (with consonant replacement) |
| `lok` + `x`          | `lo̍k`    | Eighth tone                               |
| `sann`               | `saⁿ`    | Nasalization (nn → ⁿ)                     |
| `z`                  | `ch`     | Consonant replacement                     |
| `c`                  | `chh`    | Consonant replacement                     |
| `taid` + `f` + `giv` | `tâi-gí` | Hyphen shorthand (f)                      |

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

```sh
cmake --install build
# or if you use mise
mise run install
```

- On first time installation, log out and log back in, then in `System Settings` -> `Keyboard` -> `Input Sources` (Edit), `Tâi-gí Telex` from `Chinese, Traditional`.
- On further installations, switch to another input method, `pkill TaigiTelex`, then switch back.

### Package

To build a distributable PKG installer:

```sh
mise run package
```

The PKG will be created at `build/TaigiTelex-x.x.x.pkg`.

## Acknowledgement

- [toyimk](https://github.com/eagleoflqj/toyimk) Thanks toyimk for the build system setup
- [macSKK](https://github.com/mtgto/macSKK) Thanks macSKK for architecture reference
