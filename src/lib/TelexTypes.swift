import Foundation

public enum InputMode: String {
  case tl = "com.kahiok.inputmethod.TaigiTelexTL"
  case poj = "com.kahiok.inputmethod.TaigiTelexPOJ"
}

public enum TelexState {
  case empty
  case composing(raw: String, display: String)
}

public enum TelexResult {
  case update(display: String)
  case commitAndPassthrough(String, String)
  case commitRawAndProcess(String, Character)
  case commitAndProcess(String, Character)  // Commit current, then process char as new input
  case commit(String)  // Commit and consume the character (don't process it)
}

public enum TelexKeys {
  public static let toneKeys: Set<Character> = [
    "v", "y", "d", "w", "x", "q", "V", "Y", "D", "W", "X", "Q",
  ]

  public static let consonantKeys: Set<Character> = ["z", "c", "Z", "C"]
  public static let hyphenKeys: Set<Character> = ["f", "F"]

  /// POJ-specific keys
  public static let doubleTransformKeysPOJ: Set<Character> = ["n", "o", "N", "O"]

  public static func isToneKey(_ char: Character?) -> Bool {
    guard let char else { return false }
    return toneKeys.contains(char)
  }

  public static func isConsonantReplacementKey(_ char: Character?) -> Bool {
    guard let char else { return false }
    return consonantKeys.contains(char)
  }

  public static func isHyphenKey(_ char: Character) -> Bool {
    hyphenKeys.contains(char)
  }

  public static func isLetter(_ char: Character) -> Bool {
    (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
  }

  public static func isDoubleTransformKey(_ char: Character, mode: InputMode) -> Bool {
    guard mode == .poj else { return false }
    return doubleTransformKeysPOJ.contains(char)
  }
}
