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
}
