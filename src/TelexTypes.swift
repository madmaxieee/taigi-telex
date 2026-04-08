import Foundation

enum InputMode: String {
    case tl = "com.kahiok.inputmethod.TaigiTelexTL"
    case poj = "com.kahiok.inputmethod.TaigiTelexPOJ"
}

enum TelexState {
    case empty
    case composing(raw: String, display: String)
}

enum TelexResult {
    case update(display: String)
    case commitAndPassthrough(String, String)
    case commitRawAndProcess(String, Character)
    case commitAndProcess(String, Character) // Commit current, then process char as new input
    case commit(String) // Commit and consume the character (don't process it)
}

enum TelexKeys {
    static let toneKeys: Set<Character> = ["v", "y", "d", "w", "x", "q", "V", "Y", "D", "W", "X", "Q"]

    // TL-specific keys
    static let consonantKeysTL: Set<Character> = ["z", "c", "Z", "C"]
    static let hyphenKey: Character = "f"
    static let hyphenKeyUpper: Character = "F"

    /// POJ-specific keys
    static let doubleVowelKeysPOJ: Set<Character> = ["n", "o", "N", "O"]

    static func isToneKey(_ char: Character?) -> Bool {
        guard let char else { return false }
        return toneKeys.contains(char)
    }

    static func isConsonantKey(_ char: Character?, mode: InputMode) -> Bool {
        guard let char else { return false }
        switch mode {
        case .tl:
            return consonantKeysTL.contains(char)
        case .poj:
            // In POJ, z and c are consonant keys
            return ["z", "c", "Z", "C"].contains(char)
        }
    }

    static func isHyphenKey(_ char: Character) -> Bool {
        char == hyphenKey || char == hyphenKeyUpper
    }

    static func isLetter(_ char: Character) -> Bool {
        (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
    }

    static func isDoubleVowelKey(_ char: Character, mode: InputMode) -> Bool {
        guard mode == .poj else { return false }
        return doubleVowelKeysPOJ.contains(char)
    }
}
