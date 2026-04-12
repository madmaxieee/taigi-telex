import Testing

@testable import TaigiTelexLib

/// Helper function to process a string through the TelexEngine character by character.
/// - Parameters:
///   - input: The string to process
///   - engine: The TelexEngine instance to use
/// - Returns: An array of TelexResult, one for each character processed
func processString(_ input: String, engine: TelexEngine) -> [TelexResult] {
  var results: [TelexResult] = []
  for char in input {
    let result = engine.process(char)
    results.append(result)
  }
  return results
}

@Suite("TelexEngine Tests")
struct TelexEngineTests {

  @Suite("Initialization")
  struct InitializationTests {
    @Test("Engine initializes with TL mode")
    func initializesWithTLMode() {
      let engine = TelexEngine(inputMode: .tl)
      #expect(engine.inputMode == .tl)
      #expect(engine.isEmpty == true)
    }

    @Test("Engine initializes with POJ mode")
    func initializesWithPOJMode() {
      let engine = TelexEngine(inputMode: .poj)
      #expect(engine.inputMode == .poj)
      #expect(engine.isEmpty == true)
    }
  }

  @Suite("Empty State Processing")
  struct EmptyStateProcessingTests {
    @Test("Letter starts composing", arguments: [InputMode.tl, InputMode.poj])
    func letterStartsComposing(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("a")

      #expect(result == .update(display: "a"))
      #expect(engine.isEmpty == false)
    }

    @Test("Non-letter passes through", arguments: [InputMode.tl, InputMode.poj])
    func nonLetterPassesThrough(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("1")

      #expect(result == .commitAndPassthrough(""))
      #expect(engine.isEmpty == true)
    }

    @Test("Space passes through", arguments: [InputMode.tl, InputMode.poj])
    func spacePassesThrough(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process(" ")

      #expect(result == .commitAndPassthrough(""))
      #expect(engine.isEmpty == true)
    }

    @Test("Consonant key starts composing", arguments: [InputMode.tl, InputMode.poj])
    func consonantKeyStartsComposing(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("z")

      let expectedDisplay = mode == .tl ? "ts" : "ch"
      #expect(result == .update(display: expectedDisplay))
      #expect(engine.isEmpty == false)
    }
  }

  @Suite("Continue Composing")
  struct ContinueComposingTests {
    @Test("Continue with letters", arguments: [InputMode.tl, InputMode.poj])
    func continueWithLetters(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("si", engine: engine)

      #expect(results.last == .update(display: "si"))
    }

    @Test("Build complete syllable", arguments: [InputMode.tl, InputMode.poj])
    func buildCompleteSyllable(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("tai", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "t"))
      #expect(results[1] == .update(display: "ta"))
      #expect(results[2] == .update(display: "tai"))
    }
  }

  @Suite("Tone Key Processing")
  struct ToneKeyProcessingTests {
    @Test("Apply tone to syllable", arguments: [InputMode.tl, InputMode.poj])
    func applyToneToSyllable(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("av", engine: engine)

      #expect(results.last == .update(display: "á"))
    }

    @Test("Different tone overrides existing tone", arguments: [InputMode.tl, InputMode.poj])
    func differentToneOverrides(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avy", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "á"))
      #expect(results[2] == .update(display: "à"))
    }

    @Test("Same tone key escapes and commits", arguments: [InputMode.tl, InputMode.poj])
    func sameToneKeyEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("avv", engine: engine)

      #expect(results.count == 3)
      #expect(results[0] == .update(display: "a"))
      #expect(results[1] == .update(display: "á"))
      #expect(results[2] == .commitAndProcess("a", "v"))
      #expect(engine.isEmpty == true)
    }
  }

  @Suite("Consonant Escape")
  struct ConsonantEscapeTests {
    @Test("Double z escapes and commits", arguments: [InputMode.tl, InputMode.poj])
    func doubleZEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("zz", engine: engine)

      #expect(results.count == 2)
      #expect(results[1] == .commit("z"))
      #expect(engine.isEmpty == true)
    }

    @Test("Double c escapes and commits", arguments: [InputMode.tl, InputMode.poj])
    func doubleCEscapes(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("cc", engine: engine)

      #expect(results.count == 2)
      #expect(results[1] == .commit("c"))
      #expect(engine.isEmpty == true)
    }

    @Test("z in middle of word escapes and commits raw", arguments: [InputMode.tl, InputMode.poj])
    func zInMiddleEscapesAndCommitsRaw(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("azz", engine: engine)

      #expect(results.last == .commit("az"))
    }
  }

  @Suite("Hyphen Key Processing")
  struct HyphenKeyTests {
    @Test("Hyphen key commits and processes", arguments: [InputMode.tl, InputMode.poj])
    func hyphenKeyCommitsAndProcesses(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("sif", engine: engine)

      #expect(results.last == .commitAndProcess("si", "f"))
      #expect(engine.isEmpty == true)
    }

    @Test(
      "Hyphen key starts composing when buffer empty", arguments: [InputMode.tl, InputMode.poj])
    func hyphenKeyStartsComposingWhenEmpty(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("f")

      // f is a letter, so it starts composing and gets transformed to hyphen
      #expect(result == .update(display: "-"))
    }
  }

  @Suite("Non-Letter Character Processing")
  struct NonLetterCharacterTests {
    @Test("Number commits current buffer", arguments: [InputMode.tl, InputMode.poj])
    func numberCommitsBuffer(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("a1", engine: engine)

      #expect(results.last == .commitAndPassthrough("a"))
      #expect(engine.isEmpty == true)
    }

    @Test("Punctuation commits current buffer", arguments: [InputMode.tl, InputMode.poj])
    func punctuationCommitsBuffer(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("si.", engine: engine)

      #expect(results.last == .commitAndPassthrough("si"))
      #expect(engine.isEmpty == true)
    }

    @Test("Space commits current buffer", arguments: [InputMode.tl, InputMode.poj])
    func spaceCommitsBuffer(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("a ", engine: engine)

      #expect(results.last == .commitAndPassthrough("a"))
      #expect(engine.isEmpty == true)
    }
  }

  @Suite("POJ Double Transform Escape")
  struct POJDoubleTransformEscapeTests {
    @Test("Triple n escapes in POJ")
    func tripleNEscapesInPOJ() {
      let engine = TelexEngine(inputMode: .poj)
      let results = processString("annn", engine: engine)

      // The escape commits the raw without the last char (which is the escape trigger)
      // So "a" -> drop last 2 -> "a" -> transform -> "a" + last two raw "nn" = "ann"
      #expect(results.last == .commit("ann"))
      #expect(engine.isEmpty == true)
    }

    @Test("Triple n does not escape in TL")
    func tripleNDoesNotEscapeInTL() {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("annn", engine: engine)

      // In TL, nnn just continues composing - no transformation applied to nnn
      #expect(results.last == .update(display: "annn"))
    }

    @Test("Triple o escapes in POJ")
    func tripleOOEscapesInPOJ() {
      let engine = TelexEngine(inputMode: .poj)
      let results = processString("hooo", engine: engine)

      #expect(results.last == .commit("hoo"))
      #expect(engine.isEmpty == true)
    }

    @Test("Triple o does not escape in TL")
    func tripleOODoesNotEscapeInTL() {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("hooo", engine: engine)

      // In TL, ooo just continues composing - no transformation applied to ooo
      #expect(results.last == .update(display: "hooo"))
    }
  }

  @Suite("Complex Input Scenarios")
  struct ComplexInputScenariosTests {
    @Test("Type complete word with tone")
    func typeCompleteWordWithTone() {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("taiv", engine: engine)

      #expect(results.count == 4)
      #expect(results[0] == .update(display: "t"))
      #expect(results[1] == .update(display: "ta"))
      #expect(results[2] == .update(display: "tai"))
      #expect(results[3] == .update(display: "ta\u{0301}i"))
    }

    @Test("Type word with consonant mapping and tone")
    func typeWordWithConsonantMappingAndTone() {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("zav", engine: engine)

      #expect(results.last == .update(display: "tsa\u{0301}"))
    }

    @Test("Type word with hyphen")
    func typeWordWithHyphen() {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("huanfi.", engine: engine)

      #expect(results.count == 7)
      #expect(results[4] == .commitAndProcess("huan", "f"))
      #expect(results[5] == .update(display: "i"))
      #expect(results[6] == .commitAndPassthrough("i"))
    }

    @Test("Multiple words separated by space")
    func multipleWordsSeparatedBySpace() {
      let engine = TelexEngine(inputMode: .tl)
      let results = processString("ta gi", engine: engine)

      #expect(results.count == 5)
      #expect(results[2] == .commitAndPassthrough("ta"))
      #expect(results[3] == .update(display: "g"))
      #expect(results[4] == .update(display: "gi"))
      #expect(engine.isEmpty == false)  // "gi" still in buffer
    }
  }

  @Suite("Backspace Processing")
  struct BackspaceProcessingTests {
    @Test("Backspace in empty state returns nil")
    func backspaceInEmptyState() {
      let engine = TelexEngine(inputMode: .tl)
      let result = engine.backspace()

      #expect(result == nil)
    }

    @Test("Backspace clears single character")
    func backspaceClearsSingleCharacter() {
      let engine = TelexEngine(inputMode: .tl)
      _ = processString("a", engine: engine)
      let result = engine.backspace()

      #expect(result == .update(display: ""))
      #expect(engine.isEmpty == true)
    }

    @Test("Backspace removes last character")
    func backspaceRemovesLastCharacter() {
      let engine = TelexEngine(inputMode: .tl)
      _ = processString("tai", engine: engine)
      let result = engine.backspace()

      #expect(result == .update(display: "ta"))
    }

    @Test("Backspace after consonant mapping")
    func backspaceAfterConsonantMapping() {
      let engine = TelexEngine(inputMode: .tl)
      _ = processString("z", engine: engine)
      let result = engine.backspace()

      #expect(result == .update(display: ""))
      #expect(engine.isEmpty == true)
    }
  }

  @Suite("Reset")
  struct ResetTests {
    @Test("Reset clears buffer")
    func resetClearsBuffer() {
      let engine = TelexEngine(inputMode: .tl)
      _ = processString("ta", engine: engine)
      #expect(engine.isEmpty == false)

      engine.reset()
      #expect(engine.isEmpty == true)
    }
  }

  @Suite("Case Sensitivity")
  struct CaseSensitivityTests {
    @Test("Uppercase letter starts composing", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseLetterStartsComposing(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("A")

      #expect(result == .update(display: "A"))
    }

    @Test("Mixed case composing", arguments: [InputMode.tl, InputMode.poj])
    func mixedCaseComposing(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("Ta", engine: engine)

      #expect(results.last == .update(display: "Ta"))
    }

    @Test("Uppercase consonant mapping", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseConsonantMapping(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let result = engine.process("Z")

      #expect(result == .update(display: mode == .tl ? "Ts" : "Ch"))
    }

    @Test("Uppercase tone key", arguments: [InputMode.tl, InputMode.poj])
    func uppercaseToneKey(mode: InputMode) {
      let engine = TelexEngine(inputMode: mode)
      let results = processString("aV", engine: engine)

      // Tone key V produces combining acute on the vowel
      #expect(results.last == .update(display: "á"))
    }
  }
}
