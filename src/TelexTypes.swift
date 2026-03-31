import Foundation

enum TelexState {
    case empty
    case composing(raw: String, display: String)
}

enum TelexResult {
    case update(display: String)
    case commitAndPassthrough(String, String)
    case commitRawAndProcess(String, Character)
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
    
    static func isConsonantKey(_ char: Character) -> Bool {
        return consonantKeys.contains(char)
    }
    
    static func isHyphenKey(_ char: Character) -> Bool {
        return char == hyphenKey || char == hyphenKeyUpper
    }
    
    static func isCommitTrigger(_ char: Character) -> Bool {
        if char == " " { return true }
        if char == hyphenKey { return false }
        if char == hyphenKeyUpper { return false }
        // Punctuation marks that should trigger commit
        let punctuation: Set<Character> = [".", ",", "?", "!", ";", ":", "'", "\"", "(", ")", "[", "]", "{", "}", "/", "\\", "<", ">"]
        return punctuation.contains(char)
    }
}
