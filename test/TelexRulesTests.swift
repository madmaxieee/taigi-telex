import Testing

@testable import TaigiTelexLib

@Suite("TelexRules Tests")
struct TelexRulesTests {

  @Suite("Apply Consonant Mapping")
  struct ApplyConsonantMappingTests {
    @Test("TL mode consonant mapping")
    func tlConsonantMapping() {
      // z -> ts
      #expect(TelexRules.applyConsonantMapping("z", mode: .tl) == "ts")
      #expect(TelexRules.applyConsonantMapping("Z", mode: .tl) == "Ts")
      #expect(TelexRules.applyConsonantMapping("za", mode: .tl) == "tsa")
      #expect(TelexRules.applyConsonantMapping("zan", mode: .tl) == "tsan")

      // c -> tsh
      #expect(TelexRules.applyConsonantMapping("c", mode: .tl) == "tsh")
      #expect(TelexRules.applyConsonantMapping("C", mode: .tl) == "Tsh")
      #expect(TelexRules.applyConsonantMapping("ca", mode: .tl) == "tsha")
      #expect(TelexRules.applyConsonantMapping("can", mode: .tl) == "tshan")
    }

    @Test("POJ mode consonant mapping")
    func pojConsonantMapping() {
      // z -> ch
      #expect(TelexRules.applyConsonantMapping("z", mode: .poj) == "ch")
      #expect(TelexRules.applyConsonantMapping("Z", mode: .poj) == "Ch")
      #expect(TelexRules.applyConsonantMapping("za", mode: .poj) == "cha")
      #expect(TelexRules.applyConsonantMapping("zan", mode: .poj) == "chan")

      // c -> chh
      #expect(TelexRules.applyConsonantMapping("c", mode: .poj) == "chh")
      #expect(TelexRules.applyConsonantMapping("C", mode: .poj) == "Chh")
      #expect(TelexRules.applyConsonantMapping("ca", mode: .poj) == "chha")
      #expect(TelexRules.applyConsonantMapping("can", mode: .poj) == "chhan")
    }

    @Test("Unchanged characters")
    func unchangedCharacters() {
      #expect(TelexRules.applyConsonantMapping("a", mode: .tl) == "a")
      #expect(TelexRules.applyConsonantMapping("b", mode: .tl) == "b")
      #expect(TelexRules.applyConsonantMapping("p", mode: .tl) == "p")
      #expect(TelexRules.applyConsonantMapping("t", mode: .tl) == "t")
      #expect(TelexRules.applyConsonantMapping("m", mode: .tl) == "m")
      #expect(TelexRules.applyConsonantMapping("ng", mode: .tl) == "ng")
    }

    @Test("Complex words")
    func complexWords() {
      // c -> tsh in TL, c -> chh in POJ; h and other chars unchanged
      #expect(TelexRules.applyConsonantMapping("cit", mode: .tl) == "tshit")
      #expect(TelexRules.applyConsonantMapping("cit", mode: .poj) == "chhit")
      #expect(TelexRules.applyConsonantMapping("zit", mode: .tl) == "tsit")
      #expect(TelexRules.applyConsonantMapping("zit", mode: .poj) == "chit")
    }
  }

  @Suite("Apply Hyphen Mapping")
  struct ApplyHyphenMappingTests {
    @Test("Lowercase f to hyphen")
    func lowercaseF() {
      #expect(TelexRules.applyHyphenMapping("f") == "-")
      #expect(TelexRules.applyHyphenMapping("sif") == "si-")
      #expect(TelexRules.applyHyphenMapping("huanfi") == "huan-i")
    }

    @Test("Uppercase F to hyphen")
    func uppercaseF() {
      #expect(TelexRules.applyHyphenMapping("F") == "-")
      #expect(TelexRules.applyHyphenMapping("siF") == "si-")
      #expect(TelexRules.applyHyphenMapping("HuanFi") == "Huan-i")
    }

    @Test("Mixed case")
    func mixedCase() {
      #expect(TelexRules.applyHyphenMapping("aFb") == "a-b")
      #expect(TelexRules.applyHyphenMapping("sIF") == "sI-")
    }

    @Test("No f characters")
    func noFCharacters() {
      #expect(TelexRules.applyHyphenMapping("abc") == "abc")
      #expect(TelexRules.applyHyphenMapping("test") == "test")
      #expect(TelexRules.applyHyphenMapping("ng") == "ng")
    }

    @Test("Multiple f characters")
    func multipleF() {
      #expect(TelexRules.applyHyphenMapping("ff") == "--")
      #expect(TelexRules.applyHyphenMapping("faf") == "-a-")
      #expect(TelexRules.applyHyphenMapping("fFf") == "---")
    }
  }

  @Suite("Apply Double Vowel Mapping")
  struct ApplyDoubleVowelMappingTests {
    @Test("nn to superscript n")
    func nnToSuperscriptN() {
      #expect(TelexRules.applyDoubleVowelMapping("nn") == "ⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("NN") == "ⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("Nn") == "ⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("nN") == "ⁿ")
    }

    @Test("nn in words")
    func nnInWords() {
      #expect(TelexRules.applyDoubleVowelMapping("ann") == "aⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("enn") == "eⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("inn") == "iⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("onn") == "oⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("unn") == "uⁿ")
    }

    @Test("oo to o with combining dot")
    func ooToODot() {
      #expect(TelexRules.applyDoubleVowelMapping("oo") == "o͘")
      #expect(TelexRules.applyDoubleVowelMapping("OO") == "O͘")
      #expect(TelexRules.applyDoubleVowelMapping("Oo") == "O͘")
      #expect(TelexRules.applyDoubleVowelMapping("oO") == "o͘")
    }

    @Test("oo in words")
    func ooInWords() {
      #expect(TelexRules.applyDoubleVowelMapping("hoo") == "ho͘")
      #expect(TelexRules.applyDoubleVowelMapping("chhoo") == "chho͘")
      #expect(TelexRules.applyDoubleVowelMapping("boo") == "bo͘")
    }

    @Test("No double vowel characters")
    func noDoubleVowels() {
      #expect(TelexRules.applyDoubleVowelMapping("a") == "a")
      #expect(TelexRules.applyDoubleVowelMapping("test") == "test")
      #expect(TelexRules.applyDoubleVowelMapping("single") == "single")
    }

    @Test("Mixed content")
    func mixedContent() {
      // Both nn and oo in same word
      #expect(TelexRules.applyDoubleVowelMapping("oonn") == "o͘ⁿ")
      #expect(TelexRules.applyDoubleVowelMapping("nno") == "ⁿo")
    }
  }

  @Suite("Apply Tone Mark")
  struct ApplyToneMarkTests {
    @Test("Simple tone marks", arguments: [InputMode.tl, InputMode.poj])
    func toneMarks(mode: InputMode) {
      #expect(TelexRules.applyToneMark("av", mode: mode) == "á")  // 2nd tone
      #expect(TelexRules.applyToneMark("ay", mode: mode) == "à")  // 3rd tone
      #expect(TelexRules.applyToneMark("ad", mode: mode) == "â")  // 5th tone
      #expect(TelexRules.applyToneMark("aw", mode: mode) == "ā")  // 7th tone
      #expect(TelexRules.applyToneMark("ax", mode: mode) == "a̍")  // 8th tone
      #expect(TelexRules.applyToneMark("aq", mode: mode) == "a̋")  // 9th tone
    }

    @Test("Uppercase tone marks", arguments: [InputMode.tl, InputMode.poj])
    func tlUppercaseToneMarks(mode: InputMode) {
      #expect(TelexRules.applyToneMark("AV", mode: mode) == "Á")
      #expect(TelexRules.applyToneMark("AY", mode: mode) == "À")
      #expect(TelexRules.applyToneMark("AD", mode: mode) == "Â")
    }

    @Test("Tone marks on different vowels", arguments: [InputMode.tl, InputMode.poj])
    func toneMarksOnVowels(mode: InputMode) {
      #expect(TelexRules.applyToneMark("ev", mode: mode) == "é")
      #expect(TelexRules.applyToneMark("iv", mode: mode) == "í")
      #expect(TelexRules.applyToneMark("ov", mode: mode) == "ó")
      #expect(TelexRules.applyToneMark("uv", mode: mode) == "ú")
    }

    @Test("Tone marks on syllabic consonants", arguments: [InputMode.tl, InputMode.poj])
    func toneMarksOnSyllabicConsonants(mode: InputMode) {
      #expect(TelexRules.applyToneMark("mv", mode: mode) == "ḿ")
      #expect(TelexRules.applyToneMark("ngv", mode: mode) == "ńg")
    }

    @Test(
      "Tone key preserved when no valid tone position", arguments: [InputMode.tl, InputMode.poj])
    func toneKeyPreservedWhenNoTonePosition(mode: InputMode) {
      #expect(TelexRules.applyToneMark("bv", mode: mode) == "bv")
      #expect(TelexRules.applyToneMark("tv", mode: mode) == "tv")
      #expect(TelexRules.applyToneMark("xy", mode: mode) == "xy")
    }
  }

  @Suite("Tone Positioning")
  struct TonePositioningTests {

    @Suite("TL mode exceptions")
    struct TLExceptionsTests {
      @Test("iu -> mark on u")
      func iuMarksOnU() {
        #expect(TelexRules.findTonePosition("iu", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("kiu", mode: .tl) == 2)
        #expect(TelexRules.findTonePosition("niu", mode: .tl) == 2)
      }

      @Test("ui -> mark on i")
      func uiMarksOnI() {
        #expect(TelexRules.findTonePosition("ui", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("tui", mode: .tl) == 2)
        #expect(TelexRules.findTonePosition("sui", mode: .tl) == 2)
      }

      @Test("Case insensitivity for exceptions")
      func caseInsensitivity() {
        #expect(TelexRules.findTonePosition("IU", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("Ui", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("iU", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("UI", mode: .tl) == 1)
      }
    }

    @Suite("POJ Mode Exceptions")
    struct POJExceptionsTests {
      @Test("eo -> mark on e")
      func eoMarksOnE() {
        #expect(TelexRules.findTonePosition("eo", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("heo", mode: .poj) == 1)
      }

      @Test("oe -> mark on o")
      func oeMarksOnO() {
        #expect(TelexRules.findTonePosition("oe", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("hoe", mode: .poj) == 1)
      }

      @Test("Case insensitivity for exceptions")
      func caseInsensitivity() {
        #expect(TelexRules.findTonePosition("EO", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("Eo", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("eO", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("OE", mode: .poj) == 0)
      }
    }

    @Suite("Vowel Priority Rules")
    struct PriorityRulesTests {
      @Test("TL priority: a > e > o > u > i")
      func tlVowelPriority() {
        #expect(TelexRules.findTonePosition("ai", mode: .tl) == 0)
        #expect(TelexRules.findTonePosition("ia", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("au", mode: .tl) == 0)
        #expect(TelexRules.findTonePosition("ua", mode: .tl) == 1)
        #expect(TelexRules.findTonePosition("uai", mode: .tl) == 1)

        #expect(TelexRules.findTonePosition("ue", mode: .tl) == 1)

        #expect(TelexRules.findTonePosition("io", mode: .tl) == 1)
      }

      @Test("POJ priority: o͘ > a > e > o > u > i")
      func pojVowelPriority() {
        // o͘ has highest priority when in the same cluster
        #expect(TelexRules.findTonePosition("o͘", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("ao͘", mode: .poj) == 1)

        // all the usual vowels follow the same priority as TL
        #expect(TelexRules.findTonePosition("ai", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("ia", mode: .poj) == 1)
        #expect(TelexRules.findTonePosition("au", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("ua", mode: .poj) == 1)
        #expect(TelexRules.findTonePosition("uai", mode: .poj) == 1)

        // there is no "ue" in POJ

        #expect(TelexRules.findTonePosition("io", mode: .poj) == 1)
      }
    }

    @Suite("Multiple Vowel Clusters")
    struct MultipleClustersTests {
      @Test("TL mode: tone on last vowel cluster")
      func tlMultipleClusters() {
        // taigi: t(0)a(1)i(2)g(3)i(4) -> clusters "ai" and "i", tone on last "i" at 4
        #expect(TelexRules.findTonePosition("taigi", mode: .tl) == 4)
        // haksa: h(0)a(1)k(2)s(3)a(4) -> clusters "a" and "a", tone on last "a" at 4
        #expect(TelexRules.findTonePosition("haksa", mode: .tl) == 4)
        // bunhua: b(0)u(1)n(2)h(3)u(4)a(5) -> clusters "u" and "ua", tone on "a" at 5 (a > u)
        #expect(TelexRules.findTonePosition("bunhua", mode: .tl) == 5)
        // taiwan: t(0)a(1)i(2)n(3)a(4)n(5) -> clusters "ai" and "a", tone on last "a" at 4
        #expect(TelexRules.findTonePosition("tainan", mode: .tl) == 4)
        // sengli: s(0)e(1)n(2)g(3)l(4)i(5) -> clusters "e" and "i", tone on "i" at 5
        #expect(TelexRules.findTonePosition("sengli", mode: .tl) == 5)
      }

      @Test("POJ mode with o͘: separate clusters")
      func pojMultipleClusters() {
        // cho͘a: c(0)h(1)o͘(2)a(3) -> clusters "o͘" and "a", tone on "a" at 3
        let chooa = "cho͘a"
        #expect(TelexRules.findTonePosition(chooa, mode: .poj) == 3)

        // ho͘e: h(0)o͘(1)e(2) -> clusters "o͘" and "e", tone on "e" at 2
        let hooe = "ho͘e"
        #expect(TelexRules.findTonePosition(hooe, mode: .poj) == 2)

        // ko͘ai: k(0)o͘(1)a(2)i(3) -> clusters "o͘" and "ai", tone on "a" at 2 (a > i)
        let kooai = "ko͘ai"
        #expect(TelexRules.findTonePosition(kooai, mode: .poj) == 2)

        // pho͘an: p(0)h(1)o͘(2)a(3)n(4) -> clusters "o͘" and "a", tone on "a" at 3
        let phooan = "pho͘an"
        #expect(TelexRules.findTonePosition(phooan, mode: .poj) == 3)

        // cho͘i: c(0)h(1)o͘(2)i(3) -> clusters "o͘" and "i", tone on "i" at 3
        let chooi = "cho͘i"
        #expect(TelexRules.findTonePosition(chooi, mode: .poj) == 3)
      }
    }

    @Suite("Syllabic Consonants")
    struct SyllabicConsonantsTests {
      @Test("Consonant + Vowel -> Vowel", arguments: [InputMode.tl, InputMode.poj])
      func consonantVowel(mode: InputMode) {
        #expect(TelexRules.findTonePosition("ma", mode: mode) == 1)
        #expect(TelexRules.findTonePosition("nga", mode: mode) == 2)
        #expect(TelexRules.findTonePosition("ta", mode: mode) == 1)
      }

      @Test("Vowel + Consonant -> Vowel", arguments: [InputMode.tl, InputMode.poj])
      func vowelConsonant(mode: InputMode) {
        #expect(TelexRules.findTonePosition("am", mode: mode) == 0)
        #expect(TelexRules.findTonePosition("ang", mode: mode) == 0)
        #expect(TelexRules.findTonePosition("at", mode: mode) == 0)
      }

      @Test("Syllabic ng", arguments: [InputMode.tl, InputMode.poj])
      func syllabicNg(mode: InputMode) {
        #expect(TelexRules.findTonePosition("ng", mode: mode) == 0)
        #expect(TelexRules.findTonePosition("png", mode: mode) == 1)
        #expect(TelexRules.findTonePosition("mng", mode: mode) == 1)
      }

      @Test("Syllabic m", arguments: [InputMode.tl, InputMode.poj])
      func syllabicM(mode: InputMode) {
        #expect(TelexRules.findTonePosition("m", mode: mode) == 0)
        #expect(TelexRules.findTonePosition("hm", mode: mode) == 1)
      }

      @Test("Last occurrence of ng or m", arguments: [InputMode.tl, InputMode.poj])
      func lastSyllabicConsonant(mode: InputMode) {
        // Last ng should be chosen
        #expect(TelexRules.findTonePosition("hng", mode: mode) == 1)
        // Last m should be chosen
        #expect(TelexRules.findTonePosition("hngm", mode: mode) == 3)
        // When m follows ng, m is last
        #expect(TelexRules.findTonePosition("ngm", mode: mode) == 2)
        #expect(TelexRules.findTonePosition("pngm", mode: mode) == 3)
      }
    }

    @Suite("No Tone Position Found")
    struct NoTonePositionTests {
      @Test("Empty string returns nil", arguments: [InputMode.tl, InputMode.poj])
      func emptyString(mode: InputMode) {
        #expect(TelexRules.findTonePosition("", mode: mode) == nil)
      }

      @Test("Single consonant returns nil", arguments: [InputMode.tl, InputMode.poj])
      func singleConsonant(mode: InputMode) {
        #expect(TelexRules.findTonePosition("b", mode: mode) == nil)
        #expect(TelexRules.findTonePosition("t", mode: mode) == nil)
        #expect(TelexRules.findTonePosition("s", mode: mode) == nil)
      }

      @Test("Multiple consonants returns nil", arguments: [InputMode.tl, InputMode.poj])
      func multipleConsonants(mode: InputMode) {
        #expect(TelexRules.findTonePosition("br", mode: mode) == nil)
        #expect(TelexRules.findTonePosition("tsh", mode: mode) == nil)
        #expect(TelexRules.findTonePosition("xyz", mode: mode) == nil)
      }
    }
  }

  @Suite("isDoubleTransformEscape")
  struct IsDoubleTransformEscapeTests {
    @Test("Returns false for TL mode")
    func returnsFalseForTLMode() {
      #expect(TelexRules.isDoubleTransformEscape("nn", char: "n", mode: .tl) == false)
      #expect(TelexRules.isDoubleTransformEscape("oo", char: "o", mode: .tl) == false)
    }

    @Test("Returns false for non-double-transform keys")
    func returnsFalseForNonDoubleTransformKeys() {
      #expect(TelexRules.isDoubleTransformEscape("aa", char: "a", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("zz", char: "z", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("test", char: "t", mode: .poj) == false)
    }

    @Test("Returns false for short input")
    func returnsFalseForShortInput() {
      #expect(TelexRules.isDoubleTransformEscape("n", char: "n", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("", char: "o", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("a", char: "n", mode: .poj) == false)
    }

    @Test("Detects nnn escape - lowercase")
    func detectsNnnEscapeLowercase() {
      #expect(TelexRules.isDoubleTransformEscape("nn", char: "n", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("ann", char: "n", mode: .poj) == true)
    }

    @Test("Detects nnn escape - uppercase")
    func detectsNnnEscapeUppercase() {
      #expect(TelexRules.isDoubleTransformEscape("NN", char: "N", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("ANN", char: "N", mode: .poj) == true)
    }

    @Test("Detects nnn escape - mixed case")
    func detectsNnnEscapeMixedCase() {
      #expect(TelexRules.isDoubleTransformEscape("Nn", char: "n", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("nN", char: "n", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("Nn", char: "N", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("nN", char: "N", mode: .poj) == true)
    }

    @Test("Detects ooo escape - lowercase")
    func detectsOooEscapeLowercase() {
      #expect(TelexRules.isDoubleTransformEscape("oo", char: "o", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("hoo", char: "o", mode: .poj) == true)
    }

    @Test("Detects ooo escape - uppercase")
    func detectsOooEscapeUppercase() {
      #expect(TelexRules.isDoubleTransformEscape("OO", char: "O", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("HOO", char: "O", mode: .poj) == true)
    }

    @Test("Detects ooo escape - mixed case")
    func detectsOooEscapeMixedCase() {
      #expect(TelexRules.isDoubleTransformEscape("Oo", char: "o", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("oO", char: "o", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("Oo", char: "O", mode: .poj) == true)
      #expect(TelexRules.isDoubleTransformEscape("oO", char: "O", mode: .poj) == true)
    }

    @Test("Returns false when last two chars don't match")
    func returnsFalseWhenLastTwoDontMatch() {
      #expect(TelexRules.isDoubleTransformEscape("an", char: "n", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("no", char: "n", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("ho", char: "o", mode: .poj) == false)
      #expect(TelexRules.isDoubleTransformEscape("on", char: "o", mode: .poj) == false)
    }
  }

  @Suite("isConsonantReplacementEscape")
  struct IsConsonantReplacementEscapeTests {
    @Test("Returns false for empty input")
    func returnsFalseForEmptyInput() {
      #expect(TelexRules.isConsonantReplacementEscape("", char: "z") == false)
      #expect(TelexRules.isConsonantReplacementEscape("", char: "c") == false)
    }

    @Test("Detects z escape")
    func detectsZEscape() {
      #expect(TelexRules.isConsonantReplacementEscape("z", char: "z") == true)
      #expect(TelexRules.isConsonantReplacementEscape("az", char: "z") == true)
      #expect(TelexRules.isConsonantReplacementEscape("tsaz", char: "z") == true)
    }

    @Test("Detects c escape")
    func detectsCEscape() {
      #expect(TelexRules.isConsonantReplacementEscape("c", char: "c") == true)
      #expect(TelexRules.isConsonantReplacementEscape("ac", char: "c") == true)
      #expect(TelexRules.isConsonantReplacementEscape("tshac", char: "c") == true)
    }

    @Test("Detects Z escape")
    func detectsZEscapeUppercase() {
      #expect(TelexRules.isConsonantReplacementEscape("Z", char: "Z") == true)
      #expect(TelexRules.isConsonantReplacementEscape("aZ", char: "Z") == true)
    }

    @Test("Detects C escape")
    func detectsCEscapeUppercase() {
      #expect(TelexRules.isConsonantReplacementEscape("C", char: "C") == true)
      #expect(TelexRules.isConsonantReplacementEscape("aC", char: "C") == true)
    }

    @Test("Returns false when last char doesn't match")
    func returnsFalseWhenLastCharDoesntMatch() {
      #expect(TelexRules.isConsonantReplacementEscape("a", char: "z") == false)
      #expect(TelexRules.isConsonantReplacementEscape("az", char: "c") == false)
      #expect(TelexRules.isConsonantReplacementEscape("ts", char: "z") == false)
    }

    @Test("Returns false for non-consonant keys")
    func returnsFalseForNonConsonantKeys() {
      #expect(TelexRules.isConsonantReplacementEscape("a", char: "a") == false)
      #expect(TelexRules.isConsonantReplacementEscape("n", char: "n") == false)
      #expect(TelexRules.isConsonantReplacementEscape("t", char: "t") == false)
      #expect(TelexRules.isConsonantReplacementEscape("s", char: "s") == false)
    }
  }

  @Suite("countTrailingHyphenKeys")
  struct CountTrailingHyphenKeysTests {
    @Test("Returns 0 for empty string")
    func returnsZeroForEmptyString() {
      #expect(TelexRules.countTrailingHyphenKeys("") == 0)
    }

    @Test("Returns 0 for string without trailing f")
    func returnsZeroForStringWithoutTrailingF() {
      #expect(TelexRules.countTrailingHyphenKeys("abc") == 0)
      #expect(TelexRules.countTrailingHyphenKeys("a") == 0)
      #expect(TelexRules.countTrailingHyphenKeys("test") == 0)
    }

    @Test("Returns 0 for string ending with non-f characters")
    func returnsZeroForStringEndingWithNonF() {
      #expect(TelexRules.countTrailingHyphenKeys("afz") == 0)
      #expect(TelexRules.countTrailingHyphenKeys("ffx") == 0)
    }

    @Test("Counts single trailing f")
    func countsSingleTrailingF() {
      #expect(TelexRules.countTrailingHyphenKeys("f") == 1)
      #expect(TelexRules.countTrailingHyphenKeys("af") == 1)
      #expect(TelexRules.countTrailingHyphenKeys("testf") == 1)
    }

    @Test("Counts single trailing F")
    func countsSingleTrailingUppercaseF() {
      #expect(TelexRules.countTrailingHyphenKeys("F") == 1)
      #expect(TelexRules.countTrailingHyphenKeys("aF") == 1)
      #expect(TelexRules.countTrailingHyphenKeys("testF") == 1)
    }

    @Test("Counts double trailing f")
    func countsDoubleTrailingF() {
      #expect(TelexRules.countTrailingHyphenKeys("ff") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("aff") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("testff") == 2)
    }

    @Test("Counts double trailing F")
    func countsDoubleTrailingUppercaseF() {
      #expect(TelexRules.countTrailingHyphenKeys("FF") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("aFF") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("testFF") == 2)
    }

    @Test("Counts mixed case trailing fs")
    func countsMixedCaseTrailingFs() {
      #expect(TelexRules.countTrailingHyphenKeys("fF") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("Ff") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("afF") == 2)
      #expect(TelexRules.countTrailingHyphenKeys("aFf") == 2)
    }

    @Test("Counts three or more trailing fs")
    func countsThreeOrMoreTrailingFs() {
      #expect(TelexRules.countTrailingHyphenKeys("fff") == 3)
      #expect(TelexRules.countTrailingHyphenKeys("ffff") == 4)
      #expect(TelexRules.countTrailingHyphenKeys("affff") == 4)
    }

    @Test("Stops at first non-f character")
    func stopsAtFirstNonFCharacter() {
      #expect(TelexRules.countTrailingHyphenKeys("fFfFfFfF") == 8)
      #expect(TelexRules.countTrailingHyphenKeys("affFb") == 0)
      #expect(TelexRules.countTrailingHyphenKeys("fffFfx") == 0)
    }
  }

  @Suite("Basic Syllable Test Cases from README")
  struct BasicSyllableTestCases {
    @Test("TL mode syllable transformations", arguments: SyllableTestCase.tlBasic)
    func tlSyllableTransformations(testCase: SyllableTestCase) {
      #expect(TelexRules.transform(testCase.input, mode: .tl) == testCase.output)
    }

    @Test("POJ mode syllable transformations", arguments: SyllableTestCase.pojBasic)
    func pojSyllableTransformations(testCase: SyllableTestCase) {
      #expect(TelexRules.transform(testCase.input, mode: .poj) == testCase.output)
    }
  }
}
