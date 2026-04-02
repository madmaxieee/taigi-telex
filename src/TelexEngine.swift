import Foundation

class TelexEngine {
    private(set) var state: TelexState = .empty

    func process(_ char: Character) -> TelexResult {
        switch state {
        case .empty:
            return handleEmptyState(char)

        case let .composing(currentRaw, _):
            return handleComposingState(char, currentRaw: currentRaw)
        }
    }

    private func handleEmptyState(_ char: Character) -> TelexResult {
        // Check if char is a letter - if not, pass through
        if !TelexKeys.isLetter(char) {
            return .commitAndPassthrough("", String(char))
        }

        // Start composing
        let raw = String(char)
        let display = TelexRules.transform(raw)
        state = .composing(raw: raw, display: display)
        return .update(display: display)
    }

    private func handleComposingState(_ char: Character, currentRaw: String) -> TelexResult {
        let endsWithTone = TelexKeys.isToneKey(currentRaw.last)
        let isToneChar = TelexKeys.isToneKey(char)

        // Different tone key = override the tone
        if endsWithTone && isToneChar && currentRaw.last != char {
            let newRaw = String(currentRaw.dropLast()) + String(char)
            let newDisplay = TelexRules.transform(newRaw)
            state = .composing(raw: newRaw, display: newDisplay)
            return .update(display: newDisplay)
        }

        // Same tone key = escape (commit raw without tone, process char as new)
        if endsWithTone && isToneChar && currentRaw.last == char {
            let rawToCommit = String(currentRaw.dropLast())
            state = .empty
            return .commitRawAndProcess(rawToCommit, char)
        }

        // Same consonant key = escape (commit raw consonant, don't process char)
        let endsWithConsonant = TelexKeys.isConsonantKey(currentRaw.last)
        let isConsonantChar = TelexKeys.isConsonantKey(char)
        if endsWithConsonant && isConsonantChar && currentRaw.last == char {
            // Commit the raw consonant (currentRaw is just the single consonant key)
            state = .empty
            return .commit(currentRaw)
        }

        // Hyphen key (f) = commit current and process f as new input
        if TelexKeys.isHyphenKey(char) {
            let display = TelexRules.transform(currentRaw)
            state = .empty
            return .commitAndProcess(display, char)
        }

        // Check if char is a letter - if not, it's a commit trigger
        if !TelexKeys.isLetter(char) {
            let display = TelexRules.transform(currentRaw)
            state = .empty
            return .commitAndPassthrough(display, String(char))
        }

        // Continue composing (char is a letter)
        let newRaw = currentRaw + String(char)
        let newDisplay = TelexRules.transform(newRaw)
        state = .composing(raw: newRaw, display: newDisplay)
        return .update(display: newDisplay)
    }

    func backspace() -> TelexResult? {
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
            let newDisplay = TelexRules.transform(newRaw)
            state = .composing(raw: newRaw, display: newDisplay)
            return .update(display: newDisplay)
        }
    }

    func reset() {
        state = .empty
    }

    var isEmpty: Bool {
        if case .empty = state {
            return true
        }
        return false
    }
}
