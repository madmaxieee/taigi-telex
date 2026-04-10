import Testing

@testable import TaigiTelexLib

@Suite("TelexRules Tests")
struct TelexRulesTests {

  @Suite("Tone Marks")
  struct ToneMarksTests {
    @Test("TL mode tone marks")
    func tlToneMarks() {
      #expect(TelexRules.transform("av", mode: .tl) == "a\u{0301}")  // 2nd tone
      #expect(TelexRules.transform("ay", mode: .tl) == "a\u{0300}")  // 3rd tone
      #expect(TelexRules.transform("ad", mode: .tl) == "a\u{0302}")  // 5th tone
      #expect(TelexRules.transform("aw", mode: .tl) == "a\u{0304}")  // 7th tone
      #expect(TelexRules.transform("ax", mode: .tl) == "a\u{030D}")  // 8th tone
      #expect(TelexRules.transform("aq", mode: .tl) == "a\u{030B}")  // 9th tone
    }

    @Test("TL mode uppercase tone marks")
    func tlUppercaseToneMarks() {
      #expect(TelexRules.transform("AV", mode: .tl) == "A\u{0301}")
      #expect(TelexRules.transform("AY", mode: .tl) == "A\u{0300}")
      #expect(TelexRules.transform("AD", mode: .tl) == "A\u{0302}")
    }

    @Test("Tone marks on different vowels")
    func toneMarksOnVowels() {
      #expect(TelexRules.transform("ev", mode: .tl) == "e\u{0301}")
      #expect(TelexRules.transform("iv", mode: .tl) == "i\u{0301}")
      #expect(TelexRules.transform("ov", mode: .tl) == "o\u{0301}")
      #expect(TelexRules.transform("uv", mode: .tl) == "u\u{0301}")
    }
  }

  @Suite("Tone Positioning")
  struct TonePositioningTests {

    @Suite("TL Mode Exceptions")
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
}
