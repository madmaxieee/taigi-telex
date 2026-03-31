import InputMethodKit

class ToyimkInputController: IMKInputController {
    private let engine = TelexEngine()
    
    override func inputText(_ string: String!, client sender: Any!) -> Bool {
        NSLog("Input received: \(string.debugDescription)")
        
        guard let client = sender as? IMKTextInput,
              let inputString = string,
              let firstChar = inputString.first else {
            return false
        }
        
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
            return inputText(String(newChar), client: sender)
        }
    }
    
    override func handle(_ event: NSEvent!, client sender: Any!) -> Bool {
        // Only handle key down events
        guard event.type == .keyDown else {
            return super.handle(event, client: sender)
        }
        
        // Handle backspace (keyCode 51)
        guard event.keyCode == 51 else {
            return super.handle(event, client: sender)
        }
        
        guard let client = sender as? IMKTextInput else {
            return false
        }
        
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
