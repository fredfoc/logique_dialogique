//
//  ParserTests.swift
//  LogiqueDialogique
//
//  Created by B054WO on 23/03/2026.
//

@testable import LogiqueDialogique
import Testing

struct ParserTests {
    @Test func parser() throws {
        let values = ["∀z ∃y (Qz ∧ (¬(Py ∨ Qy)))",
                      "∀x ((Pc1 ⇒ Qx) ⇒ (¬(Pc1 ⇒ ∀z (Qz))))",
                      "Pc1",
                      "Qx",
                      "(¬Pc1)",
                      "(Pc1 ∧ Qx)",
                      "(Pc1 ⇒ Qx)",
                      "(Pc1 ∨ Qx)",
                      "∀x ∃x (Pc1 ∨ Qx)",
                      "∃x (Pc1 ∨ Qx)",
                      "∀x (Pc1)"]
        try values.forEach { assertion in
            let dialogue = try Dialogue(assertion: assertion)
            #expect(dialogue.description == assertion)
        }
    }

    @Test func parserRejetteFormulesInvalides() {
        let invalidValues = [
            "",
            "P",
            "(Pc1 ∧)",
            "(⇒ Pc1 Qx)",
            "∀a (Pa)",
            "∀x (Pc1",
            "(Pc1 ∨ Qx))",
            "∃x",
        ]

        for assertion in invalidValues {
            var didThrow = false
            do {
                _ = try Dialogue(assertion: assertion)
            } catch {
                didThrow = true
            }
            #expect(didThrow)
        }
    }
}
