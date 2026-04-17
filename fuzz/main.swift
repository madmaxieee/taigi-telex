import Foundation
import TaigiTelexLib

// MARK: - Fuzz Configuration

struct FuzzConfig {
  var iterations: Int = 100_000
  var maxSequenceLength: Int = 50
  var seed: UInt64 = UInt64(Date.timeIntervalSinceReferenceDate * 1000)
}

// MARK: - Random Input Generator

struct RandomInputGenerator {
  private var rng: SeededRNG

  init(seed: UInt64) {
    self.rng = SeededRNG(seed: seed)
  }

  /// Generate a random sequence of Characters for fuzzing
  mutating func generateSequence(length: Int) -> [Character] {
    (0..<length).map { _ in randomCharacter() }
  }

  /// Generate a random length between 1 and max (inclusive)
  mutating func randomLength(max: Int) -> Int {
    Int(rng.next() % UInt64(max)) + 1
  }

  /// Generate a random Character with weighted distribution:
  /// - 70% lowercase letters (a-z)
  /// - 15% uppercase letters (A-Z)
  /// - 10% tone keys (v, y, d, w, x, q)
  /// - 5% non-letter characters (numbers, punctuation, emoji, combining chars)
  private mutating func randomCharacter() -> Character {
    let r = rng.next() % 100

    switch r {
    case 0..<70:
      // Lowercase letters
      let offset = rng.next() % 26
      return Character(UnicodeScalar(UInt8(UInt32(UnicodeScalar("a").value) + UInt32(offset))))

    case 70..<85:
      // Uppercase letters
      let offset = rng.next() % 26
      return Character(UnicodeScalar(UInt8(UInt32(UnicodeScalar("A").value) + UInt32(offset))))

    case 85..<95:
      // Tone keys (lowercase)
      let toneKeys: [Character] = ["v", "y", "d", "w", "x", "q"]
      return toneKeys[Int(rng.next() % UInt64(toneKeys.count))]

    default:
      // Non-letter characters (edge cases)
      let edgeCases: [Character] = [
        "0", "1", "9", " ", ".", ",", "!", "?",
        "-", "=", "[", "]", "\\", "/", ";", "'",
        "`", "~", "@", "#", "$", "%", "^", "&",
        "*", "(", ")", "_", "+", "{", "}", "|",
        ":", "\"", "<", ">",
        // Unicode edge cases
        "\u{0301}",  // combining acute accent
        "\u{0300}",  // combining grave accent
        "\u{00E9}",  // precomposed é
        "\u{4E00}",  // CJK character
        "\u{1F600}",  // emoji
        "\u{0000}",  // null
        "\u{000A}",  // newline
        "\u{001B}",  // escape
        "\u{FFFD}",  // replacement character
      ]
      return edgeCases[Int(rng.next() % UInt64(edgeCases.count))]
    }
  }
}

// MARK: - Simple Seeded RNG (no Foundation randomness dependency)

struct SeededRNG {
  private var state: UInt64

  init(seed: UInt64) {
    self.state = seed
  }

  mutating func next() -> UInt64 {
    // xorshift64
    state ^= state >> 12
    state ^= state << 25
    state ^= state >> 27
    return state &* 0x2545_F491_4F6C_DD1D
  }
}

// MARK: - Assertion Helpers

/// Assert that a condition holds, with detailed error message
func fuzzAssert(
  _ condition: Bool, _ message: @autoclosure () -> String, file: StaticString = #file,
  line: UInt = #line
) {
  if !condition {
    fatalError("FUZZ ASSERTION FAILED: \(message()) at \(file):\(line)")
  }
}

// MARK: - Invariant Checks

/// Check state consistency: result type must match resulting engine state
func checkStateConsistency(
  engine: TelexEngine, result: TelexResult, file: StaticString = #file, line: UInt = #line
) {
  switch result {
  case .update:
    fuzzAssert(
      !engine.isEmpty, "Expected composing state after .update, but engine is empty", file: file,
      line: line)
    if case let .composing(raw, display) = engine.state {
      fuzzAssert(
        !raw.isEmpty, "Composing state has empty raw string after .update", file: file, line: line)
      fuzzAssert(
        !display.isEmpty || raw.isEmpty, "Composing state has empty display but non-empty raw",
        file: file, line: line)
    }

  case .commit:
    fuzzAssert(
      engine.isEmpty, "Expected empty state after .commit, but engine is still composing",
      file: file, line: line)

  case .commitAndPassthrough:
    fuzzAssert(
      engine.isEmpty,
      "Expected empty state after .commitAndPassthrough, but engine is still composing", file: file,
      line: line)

  case .commitAndUpdate:
    fuzzAssert(
      !engine.isEmpty, "Expected composing state after .commitAndUpdate, but engine is empty",
      file: file, line: line)
  }
}

/// Check that escape conditions are not missed
/// If an escape condition is met, the result must NOT be .update
func checkNoMissedEscapes(
  engine: TelexEngine, char: Character, result: TelexResult,
  file: StaticString = #file, line: UInt = #line
) {
  guard case let .composing(currentRaw, _) = engine.state else { return }

  // Tone escape: same tone key pressed twice
  if TelexRules.isToneEscape(currentRaw, char: char) {
    fuzzAssert(
      !matchesUpdate(result),
      "MISSED TONE ESCAPE: isToneEscape('\(currentRaw)', '\(char)') is true, but result was .update",
      file: file, line: line
    )
    fuzzAssert(
      matchesCommit(result),
      "TONE ESCAPE WRONG RESULT: expected .commit, got \(result)",
      file: file, line: line
    )
  }

  // Consonant replacement escape: double consonant (zz, cc)
  if TelexRules.isConsonantReplacementEscape(currentRaw, char: char) {
    fuzzAssert(
      !matchesUpdate(result),
      "MISSED CONSONANT ESCAPE: isConsonantReplacementEscape('\(currentRaw)', '\(char)') is true, but result was .update",
      file: file, line: line
    )
    fuzzAssert(
      matchesCommit(result),
      "CONSONANT ESCAPE WRONG RESULT: expected .commit, got \(result)",
      file: file, line: line
    )
  }

  // POJ double transform escape: triple n or o
  if TelexRules.isDoubleTransformEscape(currentRaw, char: char, mode: engine.inputMode) {
    fuzzAssert(
      !matchesUpdate(result),
      "MISSED DOUBLE TRANSFORM ESCAPE: isDoubleTransformEscape('\(currentRaw)', '\(char)') is true, but result was .update",
      file: file, line: line
    )
    fuzzAssert(
      matchesCommit(result),
      "DOUBLE TRANSFORM ESCAPE WRONG RESULT: expected .commit, got \(result)",
      file: file, line: line
    )
  }
}

/// Check that tone override is handled correctly
func checkToneOverride(
  engine: TelexEngine, char: Character, result: TelexResult,
  file: StaticString = #file, line: UInt = #line
) {
  guard case let .composing(currentRaw, _) = engine.state else { return }

  if TelexRules.isToneOverride(currentRaw, char: char) {
    fuzzAssert(
      matchesUpdate(result),
      "TONE OVERRIDE NOT HANDLED: isToneOverride('\(currentRaw)', '\(char)') is true, but result was \(result)",
      file: file, line: line
    )
  }
}

/// Check hyphen key behavior matches expected trailing count logic
func checkHyphenBehavior(
  engine: TelexEngine, char: Character, result: TelexResult,
  file: StaticString = #file, line: UInt = #line
) {
  guard case let .composing(currentRaw, _) = engine.state else { return }
  guard TelexKeys.isHyphenKey(char) else { return }

  let trailingCount = TelexRules.countTrailingHyphenKeys(currentRaw)

  switch trailingCount {
  case 0:
    fuzzAssert(
      matchesCommitAndUpdate(result),
      "HYPHEN MISMATCH: trailingCount=0, expected .commitAndUpdate, got \(result)",
      file: file, line: line
    )

  case 1:
    fuzzAssert(
      matchesUpdate(result),
      "HYPHEN MISMATCH: trailingCount=1, expected .update, got \(result)",
      file: file, line: line
    )

  default:
    // trailingCount >= 2: should escape and commit
    fuzzAssert(
      matchesCommit(result),
      "HYPHEN MISMATCH: trailingCount=\(trailingCount), expected .commit, got \(result)",
      file: file, line: line
    )
  }
}

/// Check that non-letter input from empty state produces .commitAndPassthrough
func checkNonLetterPassthrough(
  engine: TelexEngine, char: Character, result: TelexResult,
  file: StaticString = #file, line: UInt = #line
) {
  if engine.isEmpty && !TelexKeys.isLetter(char) {
    fuzzAssert(
      matchesCommitAndPassthrough(result),
      "NON-LETTER PASSTHROUGH: expected .commitAndPassthrough for non-letter '\(char)' on empty state, got \(result)",
      file: file, line: line
    )
  }
}

/// Check that transform() never crashes on any string input
func checkTransformSafety(
  _ input: String, mode: InputMode, file: StaticString = #file, line: UInt = #line
) {
  // This will crash if transform() has index out-of-bounds or other issues
  let _ = TelexRules.transform(input, mode: mode)
}

/// Check that the same input sequence always produces the same output (determinism)
func checkDeterminism(
  sequence: [Character], mode: InputMode, file: StaticString = #file, line: UInt = #line
) {
  let engine1 = TelexEngine(inputMode: mode)
  let engine2 = TelexEngine(inputMode: mode)

  let results1 = sequence.map { engine1.process($0) }
  let results2 = sequence.map { engine2.process($0) }

  fuzzAssert(
    results1 == results2,
    "NON-DETERMINISTIC: same sequence produced different results",
    file: file, line: line
  )
}

// MARK: - Result Type Helpers

func matchesUpdate(_ result: TelexResult) -> Bool {
  if case .update = result { return true }
  return false
}

func matchesCommit(_ result: TelexResult) -> Bool {
  if case .commit = result { return true }
  return false
}

func matchesCommitAndPassthrough(_ result: TelexResult) -> Bool {
  if case .commitAndPassthrough = result { return true }
  return false
}

func matchesCommitAndUpdate(_ result: TelexResult) -> Bool {
  if case .commitAndUpdate = result { return true }
  return false
}

// MARK: - Fuzz Test Runner

func runFuzzTest(config: FuzzConfig) {
  print("🔬 Fuzz Testing Taigi Telex Engine")
  print("  Iterations: \(config.iterations)")
  print("  Max sequence length: \(config.maxSequenceLength)")
  print("  Seed: \(config.seed)")
  print("  Modes: TL, POJ")
  print("")

  var generator = RandomInputGenerator(seed: config.seed)
  var totalAssertions = 0
  var totalChars = 0

  for iteration in 0..<config.iterations {
    let sequenceLength = generator.randomLength(max: config.maxSequenceLength)
    let sequence = generator.generateSequence(length: sequenceLength)

    for mode in [InputMode.tl, InputMode.poj] {
      let engine = TelexEngine(inputMode: mode)

      for char in sequence {
        totalChars += 1

        // Run all invariant checks before processing
        checkNonLetterPassthrough(engine: engine, char: char, result: .update(display: ""))

        // Process the character
        let result = engine.process(char)

        // Run all invariant checks after processing
        checkStateConsistency(engine: engine, result: result)
        checkNoMissedEscapes(engine: engine, char: char, result: result)
        checkToneOverride(engine: engine, char: char, result: result)
        checkHyphenBehavior(engine: engine, char: char, result: result)

        // Check transform safety on current raw state
        if case let .composing(raw, _) = engine.state {
          checkTransformSafety(raw, mode: mode)
        }

        totalAssertions += 6  // 6 checks per character
      }

      // Determinism check per sequence
      checkDeterminism(sequence: sequence, mode: mode)
      totalAssertions += 1
    }

    // Progress reporting
    if (iteration + 1) % 10_000 == 0 {
      print(
        "  Progress: \(iteration + 1)/\(config.iterations) iterations (\(totalChars) chars processed)"
      )
    }
  }

  print("")
  print("✅ Fuzz test passed!")
  print("  Total assertions checked: \(totalAssertions)")
  print("  Total characters processed: \(totalChars)")
}

// MARK: - Entry Point

let config = FuzzConfig(
  iterations: Int(
    CommandLine.arguments.firstIndex(where: { $0 == "--iterations" }).map {
      Int(CommandLine.arguments[$0 + 1]) ?? 100_000
    } ?? 100_000),
  maxSequenceLength: Int(
    CommandLine.arguments.firstIndex(where: { $0 == "--max-length" }).map {
      Int(CommandLine.arguments[$0 + 1]) ?? 50
    } ?? 50),
  seed: UInt64(
    CommandLine.arguments.firstIndex(where: { $0 == "--seed" }).map {
      UInt64(CommandLine.arguments[$0 + 1]) ?? 0
    } ?? 0)
)

runFuzzTest(config: config)
