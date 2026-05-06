//
//  ContentView.swift
//  LogiqueDialogiqueApp
//
//  Created by B054WO on 13/03/2026.
//

import LogiqueDialogique
import SwiftUI
import UIKit

struct ContentView: View {
    /// samples as a static constant so we can use it for initial state
    private static let samples: [String] = [
        "∀z ∃y (Qz ∧ (¬(Py ∨ Qy)))",
        "∀x ((Pc1 ⇒ Qx) ⇒ (¬(Pc1 ⇒ ∀z (Qz))))",
        "∀x ((Pc1 ⇒ Qx) ∨ (¬(Pc1 ⇒ ∀z (Qz))))",
    ]

    /// initial dialogue is parsed from the first sample if possible
    @State private var dialogue: Dialogue = {
        if let first = ContentView.samples.first, let d = try? Dialogue(assertion: first) {
            return d
        }
        return try! Dialogue(assertion: "Pc1")
    }()

    private var parties: [Partie] {
        dialogue.parties
    }

    @State private var assertion: String = ""
    // caret position inside the assertion (nil = end)
    @State private var caretPosition: Int? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""

    /// keep a history of successfully parsed dialogues; start with the initial dialogue
    @State private var history: [Dialogue] = []

    @State private var selectedSampleIndex: Int = 0
    /// currently selected option shown in the menu label
    @State private var selectedOption: String = ""
    /// confirmation alert for clearing history
    @State private var showingClearAlert: Bool = false

    /// animation used when switching dialogues/assertions
    private let contentAnimation: Animation = .easeInOut(duration: 0.28)

    /// unique samples that aren't already present in history
    private var uniqueSamples: [String] {
        Self.samples.filter { sample in
            !history.contains(where: { $0.description == sample })
        }
    }

    /// UserDefaults key for persisted history (array of assertion strings)
    private let historyDefaultsKey = "LogiqueDialogique.history"
    /// UserDefaults key for persisted selected menu option
    private let selectedOptionDefaultsKey = "LogiqueDialogique.selectedOption"

    /// Load history from UserDefaults (parsing saved assertion strings). If nothing saved, start with first sample.
    private func loadHistory() {
        let saved = UserDefaults.standard.stringArray(forKey: historyDefaultsKey) ?? []
        var loaded: [Dialogue] = []
        for s in saved {
            if let d = try? Dialogue(assertion: s) {
                if !loaded.contains(where: { $0.description == d.description }) {
                    loaded.append(d)
                }
            }
        }
        if loaded.isEmpty {
            if let first = ContentView.samples.first, let d = try? Dialogue(assertion: first) {
                loaded = [d]
            } else if let d = try? Dialogue(assertion: "Pc1") {
                loaded = [d]
            }
        }
        history = loaded
    }

    private func saveHistory() {
        let values = history.map { $0.description }
        UserDefaults.standard.set(values, forKey: historyDefaultsKey)
    }

    private func saveSelectedOption() {
        UserDefaults.standard.set(selectedOption, forKey: selectedOptionDefaultsKey)
    }

    private func loadSelectedOption() {
        if let s = UserDefaults.standard.string(forKey: selectedOptionDefaultsKey), !s.isEmpty {
            selectedOption = s
        }
    }

    private func clearHistory() {
        UserDefaults.standard.removeObject(forKey: historyDefaultsKey)
        UserDefaults.standard.removeObject(forKey: selectedOptionDefaultsKey)
        // reset history to initial sample (or empty)
        if let first = ContentView.samples.first, let d = try? Dialogue(assertion: first) {
            history = [d]
            dialogue = d
            assertion = d.description
            selectedOption = d.description
            saveHistory()
            saveSelectedOption()
        } else {
            history = []
            selectedOption = ""
            saveHistory()
            saveSelectedOption()
        }
    }

    private func refresh() {
        do {
            let newDialogue = try Dialogue(assertion: assertion)
            withAnimation(contentAnimation) {
                dialogue = newDialogue
            }
            showError = false
            // add to history if new
            if !history.contains(where: { $0.description == dialogue.description }) {
                history.append(dialogue)
                saveHistory()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    // MARK: - Caret-aware text field wrapper

    struct CaretTextField: UIViewRepresentable {
        @Binding var text: String
        @Binding var caretPosition: Int?
        var placeholder: String
        var onCommit: () -> Void

        func makeUIView(context: Context) -> UITextField {
            let tf = UITextField(frame: .zero)
            tf.borderStyle = .roundedRect
            tf.placeholder = placeholder
            tf.delegate = context.coordinator
            tf.addTarget(context.coordinator, action: #selector(Coordinator.editingChanged(_:)), for: .editingChanged)
            tf.addTarget(context.coordinator, action: #selector(Coordinator.editingDidEndOnExit(_:)), for: .editingDidEndOnExit)
            return tf
        }

        func updateUIView(_ uiView: UITextField, context _: Context) {
            if uiView.text != text {
                uiView.text = text
            }
            // if SwiftUI provided a caret position, apply it
            if let pos = caretPosition, let start = uiView.position(from: uiView.beginningOfDocument, offset: pos) {
                uiView.selectedTextRange = uiView.textRange(from: start, to: start)
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        final class Coordinator: NSObject, UITextFieldDelegate {
            var parent: CaretTextField
            init(_ p: CaretTextField) {
                parent = p
            }

            @objc func editingChanged(_ sender: UITextField) {
                parent.text = sender.text ?? ""
                updateCaret(from: sender)
            }

            @objc func editingDidEndOnExit(_: UITextField) {
                parent.onCommit()
            }

            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                // Trigger the onCommit callback when Return is pressed
                parent.onCommit()
                textField.resignFirstResponder()
                return true
            }

            func textFieldDidChangeSelection(_ textField: UITextField) {
                updateCaret(from: textField)
            }

            private func updateCaret(from tf: UITextField) {
                if let start = tf.selectedTextRange?.start {
                    let pos = tf.offset(from: tf.beginningOfDocument, to: start)
                    parent.caretPosition = pos
                } else {
                    parent.caretPosition = nil
                }
            }
        }
    }

    /// Insert a symbol at caret position (or append if caret unknown)
    private func insertSymbolAtCaret(_ symbol: String) {
        let idx = caretPosition ?? assertion.count
        if idx < 0 || idx > assertion.count { caretPosition = assertion.count; return }
        let ns = assertion as NSString
        let range = NSRange(location: idx, length: 0)
        assertion = ns.replacingCharacters(in: range, with: symbol)
        // place caret after inserted symbol
        caretPosition = idx + symbol.count
        // SwiftUI's onChange will pick up assertion changes and refresh/append history
    }

    var body: some View {
        VStack(spacing: 0) {
            // Fixed header: input, symbols, error, history, menu and status
            VStack(alignment: .leading, spacing: 8) {
                // input with caret-aware UITextField; symbol buttons placed on the next line
                VStack(alignment: .leading, spacing: 6) {
                    CaretTextField(text: $assertion, caretPosition: $caretPosition, placeholder: "Assertion", onCommit: refresh)
                        .frame(minHeight: 36)
                        .onAppear {
                            // set assertion to the initial dialogue's assertion description
                            if assertion.isEmpty {
                                assertion = dialogue.assertion?.description ?? Self.samples.first ?? ""
                            }
                            // load persisted history (if any)
                            loadHistory()
                            // load persisted selected option (after loading history)
                            loadSelectedOption()
                            // if a persisted selected option exists, try selecting it
                            if !selectedOption.isEmpty {
                                if let match = history.first(where: { $0.description == selectedOption }) {
                                    dialogue = match
                                    assertion = match.description
                                } else if let d = try? Dialogue(assertion: selectedOption) {
                                    dialogue = d
                                    assertion = selectedOption
                                    if !history.contains(where: { $0.description == d.description }) {
                                        history.append(d)
                                        saveHistory()
                                    }
                                } else {
                                    // invalid saved option, clear it
                                    selectedOption = ""
                                    saveSelectedOption()
                                }
                            }
                            // ensure selectedSampleIndex points to the first sample by default
                            selectedSampleIndex = 0
                            // set the menu label to the initial assertion so the menu shows it immediately
                            if selectedOption.isEmpty {
                                selectedOption = assertion
                                saveSelectedOption()
                            }
                        }

                    // six symbol buttons on their own row (under the text field)
                    HStack(spacing: 8) {
                        ForEach(["∃", "∀", "∨", "∧", "⇒", "¬"], id: \.self) { sym in
                            Button(action: { insertSymbolAtCaret(sym) }) {
                                Text(sym)
                                    .font(.system(size: 18, weight: .semibold))
                                    .frame(width: 36, height: 36)
                                    .background(RoundedRectangle(cornerRadius: 6).fill(Color(UIColor.systemGray5)))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }

                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // quick history selector (recent successful dialogues)
                if !history.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(history.indices.reversed(), id: \.self) { i in
                                let d = history[i]
                                Button(action: {
                                    withAnimation(contentAnimation) {
                                        assertion = d.description
                                        dialogue = d
                                    }
                                    selectedOption = d.description
                                    saveSelectedOption()
                                }) {
                                    Text(d.description)
                                        .font(.caption)
                                        .lineLimit(1)
                                        .truncationMode(.middle)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 10)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color(UIColor.systemGray6))
                                        )
                                }
                            }
                        }
                    }
                }

                HStack(spacing: 12) {
                    // Sectioned Menu: History (first) then Samples (deduped). "Clear history" is available at the end.
                    Menu {
                        // History header and entries
                        if !history.isEmpty {
                            Text("History")
                                .font(.headline)
                                .disabled(true)
                            ForEach(history.indices.reversed(), id: \.self) { i in
                                let d = history[i]
                                Button(d.description) {
                                    selectedOption = d.description
                                    withAnimation(contentAnimation) {
                                        assertion = d.description
                                        dialogue = d
                                    }
                                    saveSelectedOption()
                                }
                            }
                            Divider()
                        }

                        // Samples header and entries (deduped against history)
                        if !uniqueSamples.isEmpty {
                            Text("Samples")
                                .font(.headline)
                                .disabled(true)
                            ForEach(uniqueSamples.indices, id: \.self) { i in
                                let s = uniqueSamples[i]
                                Button(s) {
                                    selectedOption = s
                                    assertion = s
                                    // refresh() will animate because it uses withAnimation
                                    refresh()
                                    saveSelectedOption()
                                }
                            }
                        }

                        // Clear history action
                        Divider()
                        Button(role: .destructive) {
                            // Show confirmation alert first
                            showingClearAlert = true
                        } label: {
                            Text("Clear history")
                        }
                    } label: {
                        if !selectedOption.isEmpty {
                            Text(selectedOption)
                                .lineLimit(1)
                                .truncationMode(.middle)
                        } else {
                            Text("Samples")
                        }
                    }
                }
                .animation(contentAnimation, value: dialogue.description)

                // moved: show strategy status below the menu
                Text("Has Strategie: \(dialogue.hasStrategie ? "Yes" : "No")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .animation(contentAnimation, value: dialogue.description)
            }
            .padding(.horizontal, 12)
            // make header use its intrinsic height
            .fixedSize(horizontal: false, vertical: true)

            Divider()

            // Scrollable parties list (only this area scrolls)
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(dialogue.parties, id: \.id) { partie in
                        PartieView(viewModel: PartieViewModel(partie: partie))
                    }
                }
                .padding()
            }
            // give the scroll area higher layout priority so it consumes remaining space
            .layoutPriority(1)
            .frame(maxWidth: .infinity)
            .animation(contentAnimation, value: dialogue.description)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Clear history?", isPresented: $showingClearAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                clearHistory()
            }
        } message: {
            Text("This will remove all saved history and cannot be undone.")
        }
        .onChange(of: history.count) { _, _ in
            // When history changes, ensure selectedOption is still valid; if not, reset
            let options = Self.samples + history.map { $0.description }
            if !selectedOption.isEmpty && !options.contains(selectedOption) {
                selectedOption = ""
                saveSelectedOption()
            }
        }
    }
}
