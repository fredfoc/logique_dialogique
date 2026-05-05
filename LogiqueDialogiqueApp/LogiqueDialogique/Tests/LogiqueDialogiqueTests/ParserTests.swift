//
//  ParserTests.swift
//  LogiqueDialogique
//
//  Created by B054WO on 23/03/2026.
//

@testable import LogiqueDialogique
import Testing

struct ParserTests {
    @Test func parserSpecifique() throws {
        let dialogue = try Dialogue(assertion: "∀x (((∃y (¬Py) ⇒ Pc1) ⇒ Px)")
    }

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
            assert(dialogue.description == assertion)
        }
    }
}
