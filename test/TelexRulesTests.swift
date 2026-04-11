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
      let superscriptN = "\u{207F}"
      #expect(TelexRules.applyDoubleVowelMapping("nn") == superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("NN") == superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("Nn") == superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("nN") == superscriptN)
    }

    @Test("nn in words")
    func nnInWords() {
      let superscriptN = "\u{207F}"
      #expect(TelexRules.applyDoubleVowelMapping("ann") == "a" + superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("enn") == "e" + superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("inn") == "i" + superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("onn") == "o" + superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("unn") == "u" + superscriptN)
    }

    @Test("oo to o with combining dot")
    func ooToODot() {
      let oWithDot = "o\u{0358}"
      #expect(TelexRules.applyDoubleVowelMapping("oo") == oWithDot)
      #expect(TelexRules.applyDoubleVowelMapping("OO") == "O\u{0358}")
      #expect(TelexRules.applyDoubleVowelMapping("Oo") == "O\u{0358}")
      #expect(TelexRules.applyDoubleVowelMapping("oO") == oWithDot)
    }

    @Test("oo in words")
    func ooInWords() {
      let oWithDot = "o\u{0358}"
      #expect(TelexRules.applyDoubleVowelMapping("hoo") == "h" + oWithDot)
      #expect(TelexRules.applyDoubleVowelMapping("chhoo") == "chh" + oWithDot)
      #expect(TelexRules.applyDoubleVowelMapping("boo") == "b" + oWithDot)
    }

    @Test("No double vowel characters")
    func noDoubleVowels() {
      #expect(TelexRules.applyDoubleVowelMapping("a") == "a")
      #expect(TelexRules.applyDoubleVowelMapping("test") == "test")
      #expect(TelexRules.applyDoubleVowelMapping("single") == "single")
    }

    @Test("Mixed content")
    func mixedContent() {
      let superscriptN = "\u{207F}"
      let oWithDot = "o\u{0358}"
      // Both nn and oo in same word
      #expect(TelexRules.applyDoubleVowelMapping("oonn") == oWithDot + superscriptN)
      #expect(TelexRules.applyDoubleVowelMapping("nno") == superscriptN + "o")
    }
  }

  @Suite("Apply Tone Mark")
  struct ApplyToneMarkTests {
    @Test("Simple tone marks", arguments: [InputMode.tl, InputMode.poj])
    func toneMarks(mode: InputMode) {
      #expect(TelexRules.applyToneMark("av", mode: mode) == "a\u{0301}")  // 2nd tone
      #expect(TelexRules.applyToneMark("ay", mode: mode) == "a\u{0300}")  // 3rd tone
      #expect(TelexRules.applyToneMark("ad", mode: mode) == "a\u{0302}")  // 5th tone
      #expect(TelexRules.applyToneMark("aw", mode: mode) == "a\u{0304}")  // 7th tone
      #expect(TelexRules.applyToneMark("ax", mode: mode) == "a\u{030D}")  // 8th tone
      #expect(TelexRules.applyToneMark("aq", mode: mode) == "a\u{030B}")  // 9th tone
    }

    @Test("Uppercase tone marks", arguments: [InputMode.tl, InputMode.poj])
    func tlUppercaseToneMarks(mode: InputMode) {
      #expect(TelexRules.applyToneMark("AV", mode: mode) == "A\u{0301}")
      #expect(TelexRules.applyToneMark("AY", mode: mode) == "A\u{0300}")
      #expect(TelexRules.applyToneMark("AD", mode: mode) == "A\u{0302}")
    }

    @Test("Tone marks on different vowels", arguments: [InputMode.tl, InputMode.poj])
    func toneMarksOnVowels(mode: InputMode) {
      #expect(TelexRules.applyToneMark("ev", mode: mode) == "e\u{0301}")
      #expect(TelexRules.applyToneMark("iv", mode: mode) == "i\u{0301}")
      #expect(TelexRules.applyToneMark("ov", mode: mode) == "o\u{0301}")
      #expect(TelexRules.applyToneMark("uv", mode: mode) == "u\u{0301}")
    }

    @Test("Tone marks on syllabic consonants", arguments: [InputMode.tl, InputMode.poj])
    func toneMarksOnSyllabicConsonants(mode: InputMode) {
      #expect(TelexRules.applyToneMark("mv", mode: mode) == "m\u{0301}")
      #expect(TelexRules.applyToneMark("ngv", mode: mode) == "n\u{0301}g")
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
        // o͘ has highest priority
        let oWithDot = "o\u{0358}"
        #expect(TelexRules.findTonePosition(oWithDot + "a", mode: .poj) == 0)
        #expect(TelexRules.findTonePosition("a" + oWithDot, mode: .poj) == 1)

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
}
