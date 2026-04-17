import Testing

@testable import TaigiTelexLib

@Suite("TelexEngine Edge Case Tests")
struct TelexEngineEdgeCaseTests {

  // MARK: - Hyphen Key Edge Cases

  @Suite("Hyphen Key Edge Cases")
  struct HyphenKeyEdgeCaseTests {

    @Test("Five consecutive lowercase fs: escape then restart composing", arguments: [InputMode.tl, InputMode.poj])
    func fiveConsecutiveLowercaseFs(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("fffff", engine: engine)

      #expect(results.count == 5)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "--"))
      #expect(results[2] == .commit("f"))
      #expect(results[3] == .update(display: "-"))
      #expect(results[4] == .update(display: "--"))
      #expect(engine.isEmpty == false)
    }

    @Test("Five consecutive uppercase Fs: escape then restart composing", arguments: [InputMode.tl, InputMode.poj])
    func fiveConsecutiveUppercaseFs(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("FFFFF", engine: engine)

      #expect(results.count == 5)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "--"))
      #expect(results[2] == .commit("F"))
      #expect(results[3] == .update(display: "-"))
      #expect(results[4] == .update(display: "--"))
      #expect(engine.isEmpty == false)
    }

    @Test("Alternating case fFfFf: escape on third then restart", arguments: [InputMode.tl, InputMode.poj])
    func alternatingCaseHyphenEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("fFfFf", engine: engine)

      #expect(results.count == 5)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "--"))
      #expect(results[2] == .commit("f"))
      #expect(results[3] == .update(display: "-"))
      #expect(results[4] == .update(display: "--"))
      #expect(engine.isEmpty == false)
    }

    @Test("Alternating case FfFfF: escape on third then restart", arguments: [InputMode.tl, InputMode.poj])
    func alternatingCaseHyphenEscapeUppercase(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("FfFfF", engine: engine)

      #expect(results.count == 5)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "--"))
      #expect(results[2] == .commit("F"))
      #expect(results[3] == .update(display: "-"))
      #expect(results[4] == .update(display: "--"))
      #expect(engine.isEmpty == false)
    }

    @Test("Six fs: escape twice and continue", arguments: [InputMode.tl, InputMode.poj])
    func sixConsecutiveFs(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("ffffff", engine: engine)

      #expect(results.count == 6)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "--"))
      #expect(results[2] == .commit("f"))
      #expect(results[3] == .update(display: "-"))
      #expect(results[4] == .update(display: "--"))
      #expect(results[5] == .commit("f"))
      #expect(engine.isEmpty == true)
    }

    @Test("sifff then backspace returns nil (engine empty after escape)", arguments: [InputMode.tl, InputMode.poj])
    func sifffThenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("sifff", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("siff then backspace removes one f from double hyphen", arguments: [InputMode.tl, InputMode.poj])
    func siffThenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("siff", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "-"))
      #expect(engine.isEmpty == false)
    }

    @Test("siff then f then backspace: triple escape commits then backspace returns nil", arguments: [InputMode.tl, InputMode.poj])
    func siffFThenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("sifff", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("Tone mark then hyphen: avf commits toned syllable and starts hyphen", arguments: [InputMode.tl, InputMode.poj])
    func toneMarkThenHyphen(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avf", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "a\u{0301}"))
      #expect(results[2] == .commitAndUpdate("a\u{0301}", "-"))
      #expect(engine.isEmpty == false)
    }

    @Test("Consonant escape then hyphen: zzf starts fresh hyphen", arguments: [InputMode.tl, InputMode.poj])
    func consonantEscapeThenHyphen(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zzf", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: mode == .tl ? "ts" : "ch"))
      #expect(results[1] == .commit("z"))
      #expect(results[2] == .update(display: "-"))
      #expect(engine.isEmpty == false)
    }

    @Test("Hyphen then consonant then consonant escape: ffzz commits raw with hyphens and consonant", arguments: [InputMode.tl, InputMode.poj])
    func hyphenThenConsonantEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("ffzz", engine: engine)

      #expect(results.count == 4)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "--"))
      #expect(results[2] == .update(display: mode == .tl ? "--ts" : "--ch"))
      #expect(results[3] == .commit("ffz"))
      #expect(engine.isEmpty == true)
    }

    @Test("Hyphen key after backspace: f backspace then f restarts", arguments: [InputMode.tl, InputMode.poj])
    func hyphenAfterBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = engine.process("f")
      _ = engine.backspace()
      #expect(engine.isEmpty == true)

      let result = engine.process("f")
      #expect(result == .update(display: "-"))
      #expect(engine.isEmpty == false)
    }

    @Test("Double hyphen backspace returns to single hyphen", arguments: [InputMode.tl, InputMode.poj])
    func doubleHyphenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("ff", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "-"))
      #expect(engine.isEmpty == false)
    }

    @Test("Triple f escape then backspace returns nil", arguments: [InputMode.tl, InputMode.poj])
    func tripleFEscapeThenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("fff", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("siff then backspace twice: single hyphen then empty", arguments: [InputMode.tl, InputMode.poj])
    func siffBackspaceTwice(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("siff", engine: engine)

      let result1 = engine.backspace()
      #expect(result1 == .update(display: "-"))

      let result2 = engine.backspace()
      #expect(result2 == .update(display: ""))
      #expect(engine.isEmpty == true)
    }

    @Test("Hyphen then vowel: fi composes hyphen-vowel", arguments: [InputMode.tl, InputMode.poj])
    func hyphenThenVowel(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("fi", engine: engine)

      #expect(results.count == 2)
      #expect(results[0] == .update(display: "-"))
      #expect(results[1] == .update(display: "-i"))
    }

    @Test("Word hyphen word: sifi composes correctly", arguments: [InputMode.tl, InputMode.poj])
    func wordHyphenWord(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("sifi", engine: engine)

      #expect(results.count == 4)
      #expect(results[0] == .update(display: "s"))
      #expect(results[1] == .update(display: "si"))
      #expect(results[2] == .commitAndUpdate("si", "-"))
      #expect(results[3] == .update(display: "-i"))
    }
  }

  // MARK: - Backspace Edge Cases

  @Suite("Backspace Edge Cases")
  struct BackspaceEdgeCaseTests {

    @Test("Backspace after consonant mapping clears completely", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterConsonantMappingClears(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = engine.process("z")

      let result = engine.backspace()
      #expect(result == .update(display: ""))
      #expect(engine.isEmpty == true)
    }

    @Test("Backspace after consonant mapping with preceding letter: az backspace", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterConsonantMappingWithPreceding(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("az", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "a"))
      #expect(engine.isEmpty == false)
    }

    @Test("Backspace after POJ double vowel mapping: sann backspace", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterDoubleVowelMapping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("sann", engine: engine)

      let result = engine.backspace()
      if mode == .poj {
        #expect(result == .update(display: "san"))
      } else {
        #expect(result == .update(display: "san"))
      }
      #expect(engine.isEmpty == false)
    }

    @Test("Backspace after tone mark: tav backspace returns to pre-tone state", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterToneMark(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("tav", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "ta"))
      #expect(engine.isEmpty == false)
    }

    @Test("Backspace after tone override: avy backspace removes override", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterToneOverride(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("avy", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "a"))
      #expect(engine.isEmpty == false)
    }

    @Test("Multiple consecutive backspaces: taiv backspace x4", arguments: [InputMode.tl, InputMode.poj])
    func multipleConsecutiveBackspaces(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("taiv", engine: engine)

      let r1 = engine.backspace()
      #expect(r1 == .update(display: "tai"))

      let r2 = engine.backspace()
      #expect(r2 == .update(display: "ta"))

      let r3 = engine.backspace()
      #expect(r3 == .update(display: "t"))

      let r4 = engine.backspace()
      #expect(r4 == .update(display: ""))
      #expect(engine.isEmpty == true)
    }

    @Test("Backspace to empty then continue typing", arguments: [InputMode.tl, InputMode.poj])
    func backspaceToEmptyThenContinue(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = engine.process("a")
      _ = engine.backspace()
      #expect(engine.isEmpty == true)

      let result = engine.process("b")
      #expect(result == .update(display: "b"))
      #expect(engine.isEmpty == false)
    }

    @Test("Backspace after consonant mapping c clears completely", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterCConsonantMapping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = engine.process("c")

      let result = engine.backspace()
      #expect(result == .update(display: ""))
      #expect(engine.isEmpty == true)
    }

    @Test("Backspace after complex syllable with consonant mapping and tone", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterComplexSyllable(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("zav", engine: engine)

      let result = engine.backspace()
      let expectedDisplay = mode == .tl ? "tsa" : "cha"
      #expect(result == .update(display: expectedDisplay))
      #expect(engine.isEmpty == false)
    }

    @Test("Backspace after tone escape leaves engine empty", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterToneEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("avv", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("Backspace after consonant escape leaves engine empty", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterConsonantEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("zz", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("Backspace after commitAndPassthrough leaves engine empty", arguments: [InputMode.tl, InputMode.poj])
    func backspaceAfterCommitAndPassthrough(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("a ", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }
  }

  // MARK: - Tone Mark Edge Cases

  @Suite("Tone Mark Edge Cases")
  struct ToneMarkEdgeCaseTests {

    @Test("Tone override on simple vowel: avy overrides acute with grave", arguments: [InputMode.tl, InputMode.poj])
    func toneOverrideOnSimpleVowel(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avy", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "a\u{0301}"))
      #expect(results[2] == .update(display: "a\u{0300}"))
    }

    @Test("Tone mark on syllabic consonant ng: ngv", arguments: [InputMode.tl, InputMode.poj])
    func toneMarkOnSyllabicNg(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("ngv", engine: engine)

      #expect(results.last == .update(display: "n\u{0301}g"))
    }

    @Test("Tone mark on syllabic consonant m: mv", arguments: [InputMode.tl, InputMode.poj])
    func toneMarkOnSyllabicM(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("mv", engine: engine)

      #expect(results.last == .update(display: "m\u{0301}"))
    }

    @Test("Tone mark on complex syllable with consonant mapping: ngv continues", arguments: [InputMode.tl, InputMode.poj])
    func toneMarkOnSyllabicNgWithConsonant(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("pngv", engine: engine)

      #expect(results.last == .update(display: "pn\u{0301}g"))
    }

    @Test("Tone then consonant continues composing: tavk", arguments: [InputMode.tl, InputMode.poj])
    func toneThenConsonantContinues(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("tavk", engine: engine)

      #expect(results.last == .update(display: "ta\u{0301}k"))
    }

    @Test("Tone then consonant with mapping: zavk", arguments: [InputMode.tl, InputMode.poj])
    func toneThenConsonantWithMapping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zavk", engine: engine)

      let expected = mode == .tl ? "tsa\u{0301}k" : "cha\u{0301}k"
      #expect(results.last == .update(display: expected))
    }

    @Test("Uppercase tone key V on lowercase vowel", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseToneKeyOnLowercaseVowel(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("aV", engine: engine)

      #expect(results.last == .update(display: "a\u{0301}"))
    }

    @Test("Lowercase tone key v on uppercase vowel", arguments: [InputMode.tl, InputMode.poj])
    func lowercaseToneKeyOnUppercaseVowel(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("Av", engine: engine)

      #expect(results.last == .update(display: "A\u{0301}"))
    }

    @Test("Uppercase tone key on uppercase vowel", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseToneKeyOnUppercaseVowel(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("AV", engine: engine)

      #expect(results.last == .update(display: "A\u{0301}"))
    }

    @Test("Tone key on consonant-only buffer preserves tone key: tv", arguments: [InputMode.tl, InputMode.poj])
    func toneKeyOnConsonantOnlyBuffer(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("tv", engine: engine)

      #expect(results.last == .update(display: "tv"))
    }

    @Test("Multiple tone overrides in sequence: avyd", arguments: [InputMode.tl, InputMode.poj])
    func multipleToneOverrides(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avyd", engine: engine)

      #expect(results.count == 4)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "a\u{0301}"))
      #expect(results[2] == .update(display: "a\u{0300}"))
      #expect(results[3] == .update(display: "a\u{0302}"))
    }

    @Test("Tone escape then new syllable: avv then a", arguments: [InputMode.tl, InputMode.poj])
    func toneEscapeThenNewSyllable(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avva", engine: engine)

      #expect(results.count == 4)
      #expect(results[2] == .commit("av"))
      #expect(results[3] == .update(display: "a"))
      #expect(engine.isEmpty == false)
    }

    @Test("Tone mark on diphthong iu: kiuv in TL", arguments: [InputMode.tl])
    func toneMarkOnDiphthongIuTL(mode: InputMode) {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("kiuv", engine: engine)

      #expect(results.last == .update(display: "kiu\u{0301}"))
    }

    @Test("Tone mark on diphthong ui: tuiv in TL", arguments: [InputMode.tl])
    func toneMarkOnDiphthongUiTL(mode: InputMode) {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("tuiv", engine: engine)

      #expect(results.last == .update(display: "tui\u{0301}"))
    }

    @Test("Same tone key escape with uppercase: aVV", arguments: [InputMode.tl, InputMode.poj])
    func sameToneKeyEscapeUppercase(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("aVV", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "a\u{0301}"))
      #expect(results[2] == .commit("aV"))
      #expect(engine.isEmpty == true)
    }

    @Test("Mixed case tone escape does not trigger: avV overrides tone", arguments: [InputMode.tl, InputMode.poj])
    func mixedCaseToneEscapeDoesNotTrigger(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avV", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "a\u{0301}"))
      #expect(results[2] == .update(display: "a\u{0301}"))
    }

    @Test("Tone key after tone then consonant: tavkv continues composing", arguments: [InputMode.tl, InputMode.poj])
    func toneKeyAfterToneThenConsonant(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("tavkv", engine: engine)

      #expect(results.last == .update(display: "ta\u{0301}kv"))
    }
  }

  // MARK: - Consonant Escape Edge Cases

  @Suite("Consonant Escape Edge Cases")
  struct ConsonantEscapeEdgeCaseTests {

    @Test("zz then continue typing: zza starts fresh", arguments: [InputMode.tl, InputMode.poj])
    func zzThenContinueTyping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zza", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: mode == .tl ? "ts" : "ch"))
      #expect(results[1] == .commit("z"))
      #expect(results[2] == .update(display: "a"))
      #expect(engine.isEmpty == false)
    }

    @Test("cc then backspace returns nil", arguments: [InputMode.tl, InputMode.poj])
    func ccThenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("cc", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("Mixed case zZ does NOT trigger consonant escape", arguments: [InputMode.tl, InputMode.poj])
    func mixedCaseZDoesNotEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zZ", engine: engine)

      let expectedDisplay = mode == .tl ? "tsTs" : "chCh"
      #expect(results.last == .update(display: expectedDisplay))
      #expect(engine.isEmpty == false)
    }

    @Test("Mixed case cC does NOT trigger consonant escape", arguments: [InputMode.tl, InputMode.poj])
    func mixedCaseCDoesNotEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("cC", engine: engine)

      let expectedDisplay = mode == .tl ? "tshTsh" : "chhChh"
      #expect(results.last == .update(display: expectedDisplay))
      #expect(engine.isEmpty == false)
    }

    @Test("Mixed case Zz does NOT trigger consonant escape", arguments: [InputMode.tl, InputMode.poj])
    func mixedCaseUpperZDoesNotEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("Zz", engine: engine)

      let expectedDisplay = mode == .tl ? "Tsts" : "Chch"
      #expect(results.last == .update(display: expectedDisplay))
      #expect(engine.isEmpty == false)
    }

    @Test("Uppercase ZZ triggers consonant escape", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseZZEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("ZZ", engine: engine)

      #expect(results.count == 2)
      #expect(results[0] == .update(display: mode == .tl ? "Ts" : "Ch"))
      #expect(results[1] == .commit("Z"))
      #expect(engine.isEmpty == true)
    }

    @Test("Uppercase CC triggers consonant escape", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseCCEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("CC", engine: engine)

      #expect(results.count == 2)
      #expect(results[0] == .update(display: mode == .tl ? "Tsh" : "Chh"))
      #expect(results[1] == .commit("C"))
      #expect(engine.isEmpty == true)
    }

    @Test("Consonant escape after word: azz commits az raw", arguments: [InputMode.tl, InputMode.poj])
    func consonantEscapeAfterWord(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("azz", engine: engine)

      #expect(results.last == .commit("az"))
      #expect(engine.isEmpty == true)
    }

    @Test("Consonant escape after tone: zavz continues composing then tone", arguments: [InputMode.tl, InputMode.poj])
    func consonantAfterToneMarkedSyllable(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zavz", engine: engine)

      let expected = mode == .tl ? "tsa\u{0301}ts" : "cha\u{0301}ch"
      #expect(results.last == .update(display: expected))
      #expect(engine.isEmpty == false)
    }

    @Test("Consonant escape commits raw including preceding characters", arguments: [InputMode.tl, InputMode.poj])
    func consonantEscapeCommitsRawWithPreceding(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("sizz", engine: engine)

      #expect(results.last == .commit("siz"))
      #expect(engine.isEmpty == true)
    }
  }

  // MARK: - POJ Double Transform Edge Cases

  @Suite("POJ Double Transform Edge Cases")
  struct POJDoubleTransformEdgeCaseTests {

    @Test("nnn then continue typing: nnn a starts fresh", arguments: [InputMode.poj])
    func nnnThenContinueTyping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("nnna", engine: engine)

      #expect(results.count == 4)
      #expect(results[2] == .commit("nn"))
      #expect(results[3] == .update(display: "a"))
      #expect(engine.isEmpty == false)
    }

    @Test("ooo then backspace returns nil", arguments: [InputMode.poj])
    func oooThenBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("ooo", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.backspace()
      #expect(result == nil)
    }

    @Test("Mixed case nNn triggers double transform escape in POJ", arguments: [InputMode.poj])
    func mixedCaseNnNEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("nNn", engine: engine)

      #expect(results.last == .commit("nN"))
      #expect(engine.isEmpty == true)
    }

    @Test("Mixed case oOo triggers double transform escape in POJ", arguments: [InputMode.poj])
    func mixedCaseOoOEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("oOo", engine: engine)

      #expect(results.last == .commit("oO"))
      #expect(engine.isEmpty == true)
    }

    @Test("Mixed case Nnn triggers double transform escape in POJ", arguments: [InputMode.poj])
    func mixedCaseNNNEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("Nnn", engine: engine)

      #expect(results.last == .commit("Nn"))
      #expect(engine.isEmpty == true)
    }

    @Test("sann then v: nasalization with tone mark", arguments: [InputMode.poj])
    func sannThenVowelWithTone(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("sannv", engine: engine)

      #expect(results.last == .update(display: "sa\u{0301}\u{207F}"))
    }

    @Test("hoov then v: tone escape on POJ o͘ vowel", arguments: [InputMode.poj])
    func hoovThenVEscape(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("hoovv", engine: engine)

      #expect(results.count == 5)
      #expect(results[3] == .update(display: "ho\u{0358}\u{0301}"))
      #expect(results[4] == .commit("ho\u{0358}v"))
      #expect(engine.isEmpty == true)
    }

    @Test("POJ double vowel backspace: oo backspace in POJ returns to single o", arguments: [InputMode.poj])
    func doubleVowelBackspacePOJ(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("oo", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "o"))
    }

    @Test("POJ nn backspace returns to single n", arguments: [InputMode.poj])
    func nnBackspacePOJ(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("nn", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "n"))
    }

    @Test("TL mode nnn does not escape: just continues composing", arguments: [InputMode.tl])
    func nnnDoesNotEscapeInTL(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("nnn", engine: engine)

      #expect(results.last == .update(display: "nnn"))
      #expect(engine.isEmpty == false)
    }

    @Test("TL mode ooo does not escape: just continues composing", arguments: [InputMode.tl])
    func oooDoesNotEscapeInTL(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("ooo", engine: engine)

      #expect(results.last == .update(display: "ooo"))
      #expect(engine.isEmpty == false)
    }

    @Test("POJ escape after backspace: ann backspace nn", arguments: [InputMode.poj])
    func pojEscapeAfterBackspace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("ann", engine: engine)
      _ = engine.backspace()
      #expect(engine.isEmpty == false)

      let results = processString("nn", engine: engine)
      #expect(results.last == .commit("ann"))
      #expect(engine.isEmpty == true)
    }

    @Test("POJ double vowel with consonant mapping: zann in POJ", arguments: [InputMode.poj])
    func pojDoubleVowelWithConsonantMapping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zann", engine: engine)

      #expect(results.last == .update(display: "cha\u{207F}"))
    }

    @Test("POJ double o with consonant mapping: choo in POJ", arguments: [InputMode.poj])
    func pojDoubleOWithConsonantMapping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("choo", engine: engine)

      #expect(results.last == .update(display: "chhho\u{0358}"))
    }
  }

  // MARK: - State Transition Edge Cases

  @Suite("State Transition Edge Cases")
  struct StateTransitionEdgeCaseTests {

    @Test("Process character after reset", arguments: [InputMode.tl, InputMode.poj])
    func processCharacterAfterReset(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("ta", engine: engine)
      engine.reset()
      #expect(engine.isEmpty == true)

      let result = engine.process("b")
      #expect(result == .update(display: "b"))
      #expect(engine.isEmpty == false)
    }

    @Test("Process character after commit via space", arguments: [InputMode.tl, InputMode.poj])
    func processCharacterAfterCommitViaSpace(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("a ", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.process("b")
      #expect(result == .update(display: "b"))
    }

    @Test("Empty state after multiple commits", arguments: [InputMode.tl, InputMode.poj])
    func emptyStateAfterMultipleCommits(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("a ", engine: engine)
      #expect(engine.isEmpty == true)
      _ = processString("b ", engine: engine)
      #expect(engine.isEmpty == true)
    }

    @Test("Composing after commit then new input", arguments: [InputMode.tl, InputMode.poj])
    func composingAfterCommitThenNewInput(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("av b", engine: engine)

      #expect(results.count == 4)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "a\u{0301}"))
      #expect(results[2] == .commitAndPassthrough("a\u{0301}"))
      #expect(results[3] == .update(display: "b"))
    }

    @Test("Reset during composing clears state", arguments: [InputMode.tl, InputMode.poj])
    func resetDuringComposingClearsState(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("tavk", engine: engine)
      #expect(engine.isEmpty == false)

      engine.reset()
      #expect(engine.isEmpty == true)

      let result = engine.process("a")
      #expect(result == .update(display: "a"))
    }

    @Test("Process after consonant escape commit", arguments: [InputMode.tl, InputMode.poj])
    func processAfterConsonantEscapeCommit(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("zz", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.process("a")
      #expect(result == .update(display: "a"))
    }

    @Test("Process after tone escape commit", arguments: [InputMode.tl, InputMode.poj])
    func processAfterToneEscapeCommit(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("avv", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.process("a")
      #expect(result == .update(display: "a"))
    }

    @Test("Process after hyphen escape commit", arguments: [InputMode.tl, InputMode.poj])
    func processAfterHyphenEscapeCommit(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("fff", engine: engine)
      #expect(engine.isEmpty == true)

      let result = engine.process("a")
      #expect(result == .update(display: "a"))
    }

    @Test("Rapid sequence: commit multiple syllables", arguments: [InputMode.tl, InputMode.poj])
    func rapidSequenceCommitMultiple(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avvavv", engine: engine)

      #expect(results.count == 6)
      #expect(results[2] == .commit("av"))
      #expect(results[5] == .commit("av"))
      #expect(engine.isEmpty == true)
    }

    @Test("Non-letter in empty state returns commitAndPassthrough with empty string", arguments: [InputMode.tl, InputMode.poj])
    func nonLetterInEmptyState(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process(".")

      #expect(result == .commitAndPassthrough(""))
      #expect(engine.isEmpty == true)
    }

    @Test("Number in empty state returns commitAndPassthrough with empty string", arguments: [InputMode.tl, InputMode.poj])
    func numberInEmptyState(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("5")

      #expect(result == .commitAndPassthrough(""))
      #expect(engine.isEmpty == true)
    }

    @Test("Multiple resets in sequence are idempotent", arguments: [InputMode.tl, InputMode.poj])
    func multipleResetsAreIdempotent(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("taiv", engine: engine)
      engine.reset()
      engine.reset()
      engine.reset()
      #expect(engine.isEmpty == true)

      let result = engine.process("a")
      #expect(result == .update(display: "a"))
    }

    @Test("Composing state internal values after complex input", arguments: [InputMode.tl, InputMode.poj])
    func composingStateAfterComplexInput(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("taiv", engine: engine)

      if case let .composing(raw, display) = engine.state {
        #expect(raw == "taiv")
        #expect(display == "ta\u{0301}i")
      } else {
        Issue.record("Expected composing state")
      }
    }

    @Test("Backspace restores correct state after tone on complex syllable", arguments: [InputMode.tl, InputMode.poj])
    func backspaceRestoresStateAfterToneOnComplexSyllable(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      _ = processString("taiv", engine: engine)

      let result = engine.backspace()
      #expect(result == .update(display: "tai"))

      if case let .composing(raw, display) = engine.state {
        #expect(raw == "tai")
        #expect(display == "tai")
      } else {
        Issue.record("Expected composing state")
      }
    }
  }
}
