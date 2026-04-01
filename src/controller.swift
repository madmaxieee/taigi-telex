import InputMethodKit

@objc(ToyimkInputController)
class ToyimkInputController: IMKInputController {
    private let engine = TelexEngine()

    @objc(handleEvent:client:)
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        // Only handle key down events
        guard event.type == .keyDown else {
            return false
        }

        guard let client = sender as? IMKTextInput else {
            return false
        }

        // Check for modifier keys - pass through if Command/Control/Option are pressed
        let modifierFlags = event.modifierFlags
        if modifierFlags.contains(.command) ||
           modifierFlags.contains(.control) ||
           modifierFlags.contains(.option) {
            // If we have a composition in progress, commit it first
            if !engine.isEmpty {
                commitComposition(sender)
            }
            // Pass through to system (don't handle)
            return false
        }

        // Handle backspace (keyCode 51)
        if event.keyCode == 51 {
            // Try to handle backspace in the engine
            if let result = engine.backspace() {
                switch result {
                case .update(let display):
                    if display.isEmpty {
                        // Clear marked text
                        client.setMarkedText(
                            "",
                            selectionRange: NSRange(location: 0, length: 0),
                            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
                        )
                    } else {
                        // Update marked text
                        client.setMarkedText(
                            display,
                            selectionRange: NSRange(location: display.utf16.count, length: 0),
                            replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
                        )
                    }
                    return true
                default:
                    return true
                }
            }
            // Buffer is empty, let native handle the backspace
            return false
        }

        // Handle Return key (keyCode 36) - commit if buffer not empty, otherwise pass through
        if event.keyCode == 36 {
            if !engine.isEmpty {
                // Commit current composition
                if case .composing(let raw, _) = engine.state {
                    let display = TelexRules.transform(raw)
                    client.insertText(
                        display,
                        replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
                    )
                    engine.reset()
                }
                return true  // Consumed
            }
            // Buffer empty, pass through
            return false
        }

        // Handle character input
        guard let characters = event.characters, let firstChar = characters.first else {
            return false
        }

        // Process the character through the engine
        let result = engine.process(firstChar)

        switch result {
        case .update(let display):
            // Show as marked text (underlined, in composition)
            client.setMarkedText(
                display,
                selectionRange: NSRange(location: display.utf16.count, length: 0),
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
            return true

        case .commitAndPassthrough(let committedText, _):
            // Commit the transformed text
            client.insertText(
                committedText,
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
            // Return false to let the system handle the passthrough character
            return false

        case .commitRawAndProcess(let rawText, let newChar):
            // Escape: commit raw text without transformation
            client.insertText(
                rawText,
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
            // Process the new character as fresh input
            return handle(
                NSEvent.keyEvent(
                    with: .keyDown, location: .zero, modifierFlags: [], timestamp: event.timestamp,
                    windowNumber: event.windowNumber, context: nil, characters: String(newChar),
                    charactersIgnoringModifiers: String(newChar), isARepeat: false, keyCode: 0),
                client: sender)

        case .commitAndProcess(let committedText, let newChar):
            // Commit current syllable and process new char as fresh input
            client.insertText(
                committedText,
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
            // Process the new character (hyphen) as fresh input
            return handle(
                NSEvent.keyEvent(
                    with: .keyDown, location: .zero, modifierFlags: [], timestamp: event.timestamp,
                    windowNumber: event.windowNumber, context: nil, characters: String(newChar),
                    charactersIgnoringModifiers: String(newChar), isARepeat: false, keyCode: 0),
                client: sender)
        }
    }

    override func commitComposition(_ sender: Any!) {
        guard let client = sender as? IMKTextInput else { return }

        // Commit any pending composition
        if case .composing(let raw, _) = engine.state {
            let display = TelexRules.transform(raw)
            client.insertText(
                display,
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
            engine.reset()
        }

        super.commitComposition(sender)
    }

    override func cancelComposition() {
        // Cancel composition - clear marked text without committing
        if let client = self.client() {
            client.setMarkedText(
                "",
                selectionRange: NSRange(location: 0, length: 0),
                replacementRange: NSRange(location: NSNotFound, length: NSNotFound)
            )
        }

        engine.reset()
        super.cancelComposition()
    }
}
