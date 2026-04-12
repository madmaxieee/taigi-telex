import Foundation

public class TelexEngine {
  public let inputMode: InputMode
  private(set) public var state: TelexState = .empty

  public init(inputMode: InputMode) {
    NSLog("[TaigiTelex] TelexEngine init with mode: \(inputMode)")
    self.inputMode = inputMode
    NSLog("[TaigiTelex] TelexEngine inputMode set to: \(self.inputMode)")
  }

  public func process(_ char: Character) -> TelexResult {
    switch state {
    case .empty:
      handleEmptyState(char)

    case let .composing(currentRaw, _):
      handleComposingState(char, currentRaw: currentRaw)
    }
  }

  private func handleEmptyState(_ char: Character) -> TelexResult {
    // Check if char is a letter - if not, pass through
    if !TelexKeys.isLetter(char) {
      return .commitAndPassthrough("")
    }

    // Start composing
    let raw = String(char)
    let display = TelexRules.transform(raw, mode: inputMode)
    state = .composing(raw: raw, display: display)
    return .update(display: display)
  }

  private func handleComposingState(_ char: Character, currentRaw: String) -> TelexResult {
    let endsWithTone = TelexKeys.isToneKey(currentRaw.last)
    let isToneChar = TelexKeys.isToneKey(char)

    // Different tone key = override the tone
    if endsWithTone, isToneChar, currentRaw.last != char {
      let newRaw = String(currentRaw.dropLast()) + String(char)
      let newDisplay = TelexRules.transform(newRaw, mode: inputMode)
      state = .composing(raw: newRaw, display: newDisplay)
      return .update(display: newDisplay)
    }

    // Same tone key = escape (commit current syllable and the raw tone key)
    if endsWithTone, isToneChar, currentRaw.last == char {
      let rawToCommit = String(currentRaw.dropLast())
      let displayToCommit = TelexRules.transform(rawToCommit, mode: inputMode) + String(char)
      state = .empty
      return .commit(displayToCommit)
    }

    // Same consonant key = escape (commit raw consonant, don't process char)
    if TelexRules.isConsonantReplacementEscape(currentRaw, char: char) {
      state = .empty
      return .commit(currentRaw)
    }

    // POJ: Triple n or o = escape (commit double vowel as escaped, process char)
    if TelexRules.isDoubleTransformEscape(currentRaw, char: char, mode: inputMode) {
      let escapedRaw = String(currentRaw.dropLast(2))
      let lastTwo = String(currentRaw.suffix(2))
      let display = TelexRules.transform(escapedRaw, mode: inputMode) + lastTwo
      state = .empty
      return .commit(display)
    }

    // Hyphen key handling
    if TelexKeys.isHyphenKey(char) {
      let trailingCount = TelexRules.countTrailingHyphenKeys(currentRaw)

      switch trailingCount {
      case 0:
        // No trailing f: commit current and start composing with new f
        let display = TelexRules.transform(currentRaw, mode: inputMode)
        let newRaw = String(char)
        let newDisplay = TelexRules.transform(newRaw, mode: inputMode)
        state = .composing(raw: newRaw, display: newDisplay)
        return .commitAndUpdate(display, newDisplay)

      case 1:
        // One trailing f: stay composing with "ff" -> "--"
        let newRaw = currentRaw + String(char)
        let newDisplay = TelexRules.transform(newRaw, mode: inputMode)
        state = .composing(raw: newRaw, display: newDisplay)
        return .update(display: newDisplay)

      default:
        // commit the first hyphen key and the rest of the string
        let rawAndHyphenKey = String(currentRaw.dropLast(trailingCount - 1))
        let rawToCommit = String(rawAndHyphenKey.dropLast())
        let hyphenKey = String(rawAndHyphenKey.last!)
        let display = TelexRules.transform(rawToCommit, mode: inputMode) + hyphenKey
        state = .empty
        return .commit(display)
      }
    }

    // Check if char is a letter - if not, it's a commit trigger
    if !TelexKeys.isLetter(char) {
      let display = TelexRules.transform(currentRaw, mode: inputMode)
      state = .empty
      return .commitAndPassthrough(display)
    }

    // Continue composing (char is a letter)
    let newRaw = currentRaw + String(char)
    let newDisplay = TelexRules.transform(newRaw, mode: inputMode)
    state = .composing(raw: newRaw, display: newDisplay)
    return .update(display: newDisplay)
  }

  public func backspace() -> TelexResult? {
    switch state {
    case .empty:
      // Buffer empty, let native handle
      return nil

    case let .composing(raw, _):
      if raw.count <= 1 {
        // Clear buffer
        state = .empty
        return .update(display: "")
      }

      // Remove last character
      let newRaw = String(raw.dropLast())
      let newDisplay = TelexRules.transform(newRaw, mode: inputMode)
      state = .composing(raw: newRaw, display: newDisplay)
      return .update(display: newDisplay)
    }
  }

  public func reset() {
    state = .empty
  }

  public var isEmpty: Bool {
    if case .empty = state {
      return true
    }
    return false
  }
}
