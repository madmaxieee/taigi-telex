import Foundation

enum TelexRules {
    // MARK: - Tone Marks (same for both modes)

    static let toneMarks: [Character: String] = [
        "v": "\u{0301}", // combining acute (2nd tone)
        "y": "\u{0300}", // combining grave (3rd tone)
        "d": "\u{0302}", // combining circumflex (5th tone)
        "w": "\u{0304}", // combining macron (7th tone)
        "x": "\u{030D}", // combining vertical line (8th tone)
        "q": "\u{030B}", // combining double acute (9th tone)
        "V": "\u{0301}",
        "Y": "\u{0300}",
        "D": "\u{0302}",
        "W": "\u{0304}",
        "X": "\u{030D}",
        "Q": "\u{030B}",
    ]

    // MARK: - Consonant Mappings

    static let consonantMapTL: [Character: String] = [
        "z": "ts",
        "Z": "Ts",
        "c": "tsh",
        "C": "Tsh",
    ]

    static let consonantMapPOJ: [Character: String] = [
        "z": "ch",
        "Z": "Ch",
        "c": "chh",
        "C": "Chh",
    ]

    // MARK: - Double Vowel Mappings (POJ only)

    static let doubleVowelMapPOJ: [String: String] = [
        "nn": "\u{207F}", // superscript n (ⁿ)
        "NN": "\u{207F}",
        "Nn": "\u{207F}",
        "nN": "\u{207F}",
        "oo": "o\u{0358}", // o with combining dot above right (o͘)
        "OO": "O\u{0358}",
        "Oo": "O\u{0358}",
        "oO": "o\u{0358}",
    ]

    // MARK: - Vowel Priority

    static let vowelPriorityTL = ["a", "e", "o", "u", "i"]
    static let vowelPriorityPOJ = ["o\u{0358}", "a", "e", "o", "u", "i"] // o͘ has highest priority

    // MARK: - Valid Vowels for Tone Marking

    static let validVowelsTL: Set<Character> = ["a", "e", "i", "o", "u", "m", "n"]
    static let validVowelsPOJ: Set<Character> = ["a", "e", "i", "o", "u", "m", "n", "o\u{0358}"] // include o͘

    // MARK: - Main Transform Function

    static func transform(_ input: String, mode: InputMode) -> String {
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

    // MARK: - Consonant Mapping

    private static func applyConsonantMapping(_ input: String, mode: InputMode) -> String {
        let consonantMap = mode == .tl ? consonantMapTL : consonantMapPOJ
        return input.map { char in
            consonantMap[char] ?? String(char)
        }.joined()
    }

    // MARK: - Hyphen Mapping

    private static func applyHyphenMapping(_ input: String) -> String {
        input.replacingOccurrences(of: "f", with: "-")
            .replacingOccurrences(of: "F", with: "-")
    }

    // MARK: - Double Vowel Mapping (POJ only)

    private static func applyDoubleVowelMapping(_ input: String) -> String {
        var result = input
        for (key, value) in doubleVowelMapPOJ {
            result = result.replacingOccurrences(of: key, with: value)
        }
        return result
    }

    // MARK: - Tone Mark Application

    private static func applyToneMark(_ input: String, mode: InputMode) -> String {
        guard let lastChar = input.last,
              let toneMark = toneMarks[lastChar]
        else {
            return input
        }

        // Remove the tone key from the end
        let syllable = String(input.dropLast())

        // Find position to place tone mark
        let position = findTonePosition(syllable, mode: mode)

        // Only apply tone if we found a valid vowel position
        guard position >= 0, position < syllable.count else {
            return input
        }

        // Check if the character at position is actually a vowel
        let index = syllable.index(syllable.startIndex, offsetBy: position)
        let targetChar = syllable[index].lowercased()
        if mode == .tl {
            if !validVowelsTL.contains(Character(targetChar)) {
                return input
            }
        } else {
            if !validVowelsPOJ.contains(Character(targetChar)) {
                return input
            }
        }

        // Insert combining mark after the target character
        var result = syllable
        result.insert(contentsOf: toneMark, at: syllable.index(after: index))

        return result
    }

    // MARK: - Tone Position Finding

    static func findTonePosition(_ syllable: String, mode: InputMode) -> Int {
        let lower = syllable.lowercased()
        let vowelPriority = mode == .tl ? vowelPriorityTL : vowelPriorityPOJ

        // Mode-specific exceptions
        if mode == .tl {
            // TL exceptions: iu -> mark on u, ui -> mark on i
            if let range = lower.range(of: "iu") {
                let uIndex = lower.index(range.lowerBound, offsetBy: 1)
                return syllable.distance(from: syllable.startIndex, to: uIndex)
            }

            if let range = lower.range(of: "ui") {
                let iIndex = lower.index(range.lowerBound, offsetBy: 1)
                return syllable.distance(from: syllable.startIndex, to: iIndex)
            }
        } else {
            // POJ exceptions: eo -> mark on e, oe -> mark on o
            if let range = lower.range(of: "eo") {
                let eIndex = lower.index(range.lowerBound, offsetBy: 0)
                return syllable.distance(from: syllable.startIndex, to: eIndex)
            }

            if let range = lower.range(of: "oe") {
                let oIndex = lower.index(range.lowerBound, offsetBy: 0)
                return syllable.distance(from: syllable.startIndex, to: oIndex)
            }
        }

        // Priority order: a, e, o, u, i (TL) or o͘, a, e, o, u, i (POJ)
        for vowel in vowelPriority {
            if let range = lower.range(of: vowel) {
                return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
            }
        }

        // No regular vowels found - check for syllabic consonants
        // Check for syllabic ng - only valid if no other vowels
        if lower == "ng" {
            if let range = lower.range(of: "ng") {
                return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
            }
        }

        // Check for standalone m or n or ⁿ - only valid if it's just that
        if lower == "m" || lower == "n" || lower == "\u{207F}" {
            return 0
        }

        // Check for superscript n (ⁿ) in the syllable
        if let range = lower.range(of: "\u{207F}") {
            return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
        }

        // No vowel found
        return -1
    }

    // MARK: - Check if input ends with double vowel escape pattern (POJ)

    static func isDoubleVowelEscape(_ input: String, char: Character, mode: InputMode) -> Bool {
        guard mode == .poj else { return false }
        guard TelexKeys.isDoubleVowelKey(char, mode: mode) else { return false }
        guard input.count >= 2 else { return false }

        let lastTwo = String(input.suffix(2))

        // Check if last two chars are the same and match the new char (nnn or ooo)
        if lastTwo == String(repeating: char, count: 2).lowercased() ||
            lastTwo == String(repeating: char, count: 2).uppercased() ||
            lastTwo == String(char).lowercased() + String(char).uppercased() ||
            lastTwo == String(char).uppercased() + String(char).lowercased()
        {
            return true
        }

        return false
    }

    // MARK: - Check if input ends with consonant escape pattern

    static func isConsonantEscape(_ input: String, char: Character, mode: InputMode) -> Bool {
        guard let lastChar = input.last else { return false }

        // Check if last char is same as new char and is a consonant key
        if lastChar == char, TelexKeys.isConsonantKey(char, mode: mode) {
            return true
        }

        return false
    }
}
