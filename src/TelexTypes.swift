import Foundation

enum TelexState {
    case empty
    case composing(raw: String, display: String)
}

enum TelexResult {
    case update(display: String)
    case commitAndPassthrough(String, String)
    case commitRawAndProcess(String, Character)
    case commitAndProcess(String, Character)  // Commit current, then process char as new input
    case commit(String)  // Commit and consume the character (don't process it)
}

struct TelexKeys {
    static let toneKeys: Set<Character> = ["v", "y", "d", "w", "x", "q", "V", "Y", "D", "W", "X", "Q"]
    static let consonantKeys: Set<Character> = ["z", "c", "Z", "C"]
    static let hyphenKey: Character = "f"
    static let hyphenKeyUpper: Character = "F"
    
    static func isToneKey(_ char: Character?) -> Bool {
        guard let char = char else { return false }
        return toneKeys.contains(char)
    }
    
    static func isConsonantKey(_ char: Character?) -> Bool {
        guard let char = char else { return false }
        return consonantKeys.contains(char)
    }
    
    static func isHyphenKey(_ char: Character) -> Bool {
        return char == hyphenKey || char == hyphenKeyUpper
    }
    
    static func isLetter(_ char: Character) -> Bool {
        return (char >= "a" && char <= "z") || (char >= "A" && char <= "Z")
    }
}
