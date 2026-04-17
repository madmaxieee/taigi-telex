import Foundation

public enum TelexRules {
  public static let toneMarkByToneKey: [Character: String] = [
    "v": "\u{0301}",  // combining acute (2nd tone)
    "y": "\u{0300}",  // combining grave (3rd tone)
    "d": "\u{0302}",  // combining circumflex (5th tone)
    "w": "\u{0304}",  // combining macron (7th tone)
    "x": "\u{030D}",  // combining vertical line (8th tone)
    "q": "\u{030B}",  // combining double acute (9th tone)
    "V": "\u{0301}",
    "Y": "\u{0300}",
    "D": "\u{0302}",
    "W": "\u{0304}",
    "X": "\u{030D}",
    "Q": "\u{030B}",
  ]

  public static let consonantMapTL: [Character: String] = [
    "z": "ts",
    "Z": "Ts",
    "c": "tsh",
    "C": "Tsh",
  ]

  public static let consonantMapPOJ: [Character: String] = [
    "z": "ch",
    "Z": "Ch",
    "c": "chh",
    "C": "Chh",
  ]

  public static let doubleVowelMapPOJ: [String: String] = [
    "nn": "\u{207F}",  // superscript n (ⁿ)
    "NN": "\u{207F}",
    "Nn": "\u{207F}",
    "nN": "\u{207F}",
    "oo": "o\u{0358}",  // o with combining dot above right (o͘)
    "OO": "O\u{0358}",
    "Oo": "O\u{0358}",
    "oO": "o\u{0358}",
  ]

  public static let vowelPriorityTL = ["a", "e", "o", "u", "i"]
  public static let vowelPriorityPOJ = ["o\u{0358}", "a", "e", "o", "u", "i"]  // o͘ has highest priority

  public static func transform(_ input: String, mode: InputMode) -> String {
    var result = input

    // Step 1: Apply consonant mappings
    result = applyConsonantMapping(result, mode: mode)

    // Step 2: Apply hyphen mapping
    result = applyHyphenMapping(result)

    // Step 3: Apply double vowel mappings (POJ only)
    if mode == .poj {
      result = applyDoubleVowelMapping(result)
    }

    // Step 4: Apply tone mark if present at end
    result = applyToneMark(result, mode: mode)

    return result
  }

  public static func applyConsonantMapping(_ input: String, mode: InputMode) -> String {
    let consonantMap = mode == .tl ? consonantMapTL : consonantMapPOJ
    return input.map { char in
      consonantMap[char] ?? String(char)
    }.joined()
  }

  public static func applyHyphenMapping(_ input: String) -> String {
    input.replacingOccurrences(of: "f", with: "-")
      .replacingOccurrences(of: "F", with: "-")
  }

  public static func applyDoubleVowelMapping(_ input: String) -> String {
    var result = input
    for (key, value) in doubleVowelMapPOJ {
      result = result.replacingOccurrences(of: key, with: value)
    }
    return result
  }

  public static func applyToneMark(_ input: String, mode: InputMode) -> String {
    var tonePositions: [(index: String.Index, mark: String)] = []

    for (offset, char) in input.enumerated() {
      if let toneMark = toneMarkByToneKey[char] {
        tonePositions.append(
          (index: input.index(input.startIndex, offsetBy: offset), mark: toneMark))
      }
    }

    if tonePositions.isEmpty {
      return input
    }

    var result = ""
    result.reserveCapacity(input.count)
    var prevToneEnd = input.startIndex

    for tonePos in tonePositions {
      let segment = String(input[prevToneEnd..<tonePos.index])

      if let position = findTonePosition(segment, mode: mode),
        position < segment.count
      {
        let targetIndex = segment.index(segment.startIndex, offsetBy: position)
        var applied = segment
        applied.insert(contentsOf: tonePos.mark, at: segment.index(after: targetIndex))
        result += applied
      } else {
        result += segment
      }

      prevToneEnd = input.index(after: tonePos.index)
    }

    result += String(input[prevToneEnd..<input.endIndex])

    return result
  }

  public static func findTonePosition(_ syllable: String, mode: InputMode) -> Int? {
    let lower = syllable.lowercased()
    let oWithDot = "o\u{0358}"

    // Iterate from the end to find the last vowel cluster
    var clusterEnd: Int? = nil
    var clusterStart: Int? = nil

    for (offset, char) in lower.enumerated().reversed() {
      let index = lower.index(lower.startIndex, offsetBy: offset)

      // Check for o͘ in POJ mode
      if mode == .poj && lower[index...].hasPrefix(oWithDot) {
        if clusterEnd != nil {
          // We already have a vowel cluster after o͘
          // o͘ acts as a separator, process the cluster we found
          break
        }
        // o͘ is the cluster itself (no vowels after it)
        return offset
      }

      if "aeiou".contains(char) {
        if clusterEnd == nil {
          // First vowel found from the end - this is the end of the cluster
          clusterEnd = offset
        }
        clusterStart = offset
        // Continue to find the head of the cluster
      } else if clusterEnd != nil {
        // We've found the end of the cluster and now hit a non-vowel
        // The cluster is complete
        break
      }
    }

    // If we found a vowel cluster, determine the tone position within it
    if let start = clusterStart, let end = clusterEnd {
      // Extract the vowel cluster as a substring
      let startIdx = lower.index(lower.startIndex, offsetBy: start)
      let endIdx = lower.index(lower.startIndex, offsetBy: end)
      let clusterText = String(lower[startIdx...endIdx])

      // Check for exception cases first
      if let exceptionPos = tonePositionForException(cluster: clusterText, mode: mode, start: start)
      {
        return exceptionPos
      }

      // Apply priority heuristic within the cluster
      let vowelPriority = mode == .tl ? vowelPriorityTL : vowelPriorityPOJ
      for vowel in vowelPriority {
        if let range = clusterText.range(of: vowel) {
          let offset = clusterText.distance(from: clusterText.startIndex, to: range.lowerBound)
          return start + offset
        }
      }

      // Fallback: return the start of the cluster
      return start
    }

    // No vowel cluster found, look for syllabic consonants (ng or m)
    // Search backwards for the last occurrence
    var lastNgPos: Int? = nil
    var lastMPos: Int? = nil

    for (offset, char) in lower.enumerated().reversed() {
      if char == "m" {
        // Check if this 'm' is part of an 'ng' (preceded by 'n' at position offset-1)
        let isPartOfNg =
          (offset > 0)
          && (lower[lower.index(lower.startIndex, offsetBy: offset - 1)] == "n")
        if !isPartOfNg {
          lastMPos = offset
        }
      } else if char == "n" && offset < lower.count - 1 {
        // Check if this 'n' is followed by 'g' (forms 'ng')
        let index = lower.index(lower.startIndex, offsetBy: offset)
        let nextChar = lower[lower.index(after: index)]
        if nextChar == "g" {
          lastNgPos = offset
        }
      }
    }

    // Return the last occurrence (the larger position, or either if equal)
    switch (lastMPos, lastNgPos) {
    case (let m?, let n?):
      return max(m, n)
    case (let m?, nil):
      return m
    case (nil, let n?):
      return n
    case (nil, nil):
      return nil
    }
  }

  public static func isDoubleTransformEscape(_ input: String, char: Character, mode: InputMode)
    -> Bool
  {
    guard mode == .poj else { return false }
    guard TelexKeys.isDoubleTransformKey(char, mode: mode) else { return false }
    guard input.count >= 2 else { return false }

    let lastTwo = String(input.suffix(2))

    // Check if last two chars are the same and match the new char (nnn or ooo)
    let expected = String(repeating: char, count: 2).lowercased()
    if lastTwo.lowercased() == expected {
      return true
    }

    return false
  }

  public static func isConsonantReplacementEscape(_ input: String, char: Character) -> Bool {
    guard let lastChar = input.last else { return false }

    // Check if last char is same as new char and is a consonant key
    if lastChar == char, TelexKeys.isConsonantReplacementKey(char) {
      return true
    }

    return false
  }

  /// Counts the number of trailing f/F characters at the end of the input.
  /// Used to determine hyphen key behavior based on how many trailing fs exist.
  public static func countTrailingHyphenKeys(_ input: String) -> Int {
    var count = 0
    for char in input.reversed() {
      if char == "f" || char == "F" {
        count += 1
      } else {
        break
      }
    }
    return count
  }

  /// Check if input ends with a tone key and new char is a different tone key.
  /// Used to determine if the current tone should be overridden.
  public static func isToneOverride(_ input: String, char: Character) -> Bool {
    guard let lastChar = input.last else { return false }
    guard TelexKeys.isToneKey(lastChar) else { return false }
    guard TelexKeys.isToneKey(char) else { return false }
    return lastChar != char
  }

  /// Check if input ends with a tone key and new char is the same tone key.
  /// Used to determine if we should commit and escape (escape current syllable and raw tone key).
  public static func isToneEscape(_ input: String, char: Character) -> Bool {
    guard let lastChar = input.last else { return false }
    guard TelexKeys.isToneKey(lastChar) else { return false }
    guard TelexKeys.isToneKey(char) else { return false }
    return lastChar == char
  }

  /// Check for tone position exception cases based on cluster content and input mode.
  private static func tonePositionForException(cluster: String, mode: InputMode, start: Int) -> Int?
  {
    switch mode {
    case .tl:
      if cluster == "iu" {
        return start + 1
      }
      if cluster == "ui" {
        return start + 1
      }
    case .poj:
      if cluster == "eo" {
        return start
      }
      if cluster == "oe" {
        return start
      }
    }
    return nil
  }
}
