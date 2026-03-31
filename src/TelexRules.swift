import Foundation

struct TelexRules {
    static let toneMarks: [Character: String] = [
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
    
    static let consonantMap: [Character: String] = [
        "z": "ts",
        "Z": "Ts",
        "c": "tsh",
        "C": "Tsh",
    ]
    
    static let vowelPriority = ["a", "e", "o", "u", "i"]
    
    static func transform(_ input: String) -> String {
        var result = input
        
        // Step 1: Apply consonant mappings (z→ts, c→tsh)
        result = applyConsonantMapping(result)
        
        // Step 2: Apply hyphen mapping (f→-)
        result = applyHyphenMapping(result)
        
        // Step 3: Apply tone mark if present at end
        result = applyToneMark(result)
        
        return result
    }
    
    private static func applyConsonantMapping(_ input: String) -> String {
        var result = input
        for (key, value) in consonantMap {
            result = result.replacingOccurrences(of: String(key), with: value)
        }
        return result
    }
    
    private static func applyHyphenMapping(_ input: String) -> String {
        return input.replacingOccurrences(of: "f", with: "-")
                     .replacingOccurrences(of: "F", with: "-")
    }
    
    private static func applyToneMark(_ input: String) -> String {
        guard let lastChar = input.last,
              let toneMark = toneMarks[lastChar] else {
            return input
        }
        
        // Remove the tone key from the end
        let syllable = String(input.dropLast())
        
        // Find position to place tone mark
        let position = findTonePosition(syllable)
        
        guard position >= 0 && position < syllable.count else {
            return input
        }
        
        // Insert combining mark after the target character
        let index = syllable.index(syllable.startIndex, offsetBy: position)
        _ = syllable[index]  // Verify position is valid
        
        var result = syllable
        result.insert(contentsOf: toneMark, at: syllable.index(after: index))
        
        return result
    }
    
    static func findTonePosition(_ syllable: String) -> Int {
        let lower = syllable.lowercased()
        
        // Check for 'oo' - mark goes on first 'o'
        if let range = lower.range(of: "oo") {
            return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
        }
        
        // Check for 'iu' - mark goes on 'u'
        if let range = lower.range(of: "iu") {
            let uIndex = lower.index(range.lowerBound, offsetBy: 1)
            return syllable.distance(from: syllable.startIndex, to: uIndex)
        }
        
        // Check for 'ui' - mark goes on 'i'
        if let range = lower.range(of: "ui") {
            let iIndex = lower.index(range.lowerBound, offsetBy: 1)
            return syllable.distance(from: syllable.startIndex, to: iIndex)
        }
        
        // Priority order: a, e, o, u, i
        for vowel in vowelPriority {
            if let range = lower.range(of: vowel) {
                return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
            }
        }
        
        // Syllabic consonants
        if lower.hasSuffix("ng") {
            if let range = lower.range(of: "ng") {
                return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
            }
        }
        
        if lower.hasSuffix("m") && lower.count == 1 {
            if let range = lower.range(of: "m") {
                return syllable.distance(from: syllable.startIndex, to: range.lowerBound)
            }
        }
        
        // Default: last character
        return max(0, syllable.count - 1)
    }
}
