//
//  RulesTests.swift
//  LogiqueDialogique
//
//  Created by B054WO on 13/03/2026.
//

@testable import LogiqueDialogique
import Testing

struct Test {
    private func nextCoups(for proposition: Proposition, type: TypeExpression) -> [Coup] {
        let expression = Expression(type: type, proposition: proposition, joueur: .Proposant)
        let coup = Coup(relatedStep: nil, step: 0, role: .unknown, expression: expression)
        let partie = Partie(index: 0, coups: [coup], constants: [])
        return Rules.evaluateCoup(partie: partie)
    }

    private func propositionSimple(_ name: String) -> Proposition {
        Proposition(name: name, variable: Variable(name: "x"))
    }

    @Test func reponseAssertionNegation() {
        let formuleSimple = propositionSimple("P")
        let formuleComplexe = Proposition(connecteur: .negation(formuleSimple))
        let nextCoups = nextCoups(for: formuleComplexe, type: .assertion)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .assertion)
        #expect(nextCoups[0].prop == "Px")
    }

    @Test func reponseAssertionConjonction() {
        let formuleSimple1 = propositionSimple("P")
        let formuleSimple2 = propositionSimple("Q")
        let formuleComplexe = Proposition(connecteur: .conjonction(formuleSimple1, formuleSimple2))
        let nextCoups = nextCoups(for: formuleComplexe, type: .assertion)

        #expect(nextCoups.count == 2)
        #expect(nextCoups.allSatisfy { $0.isAttaque })
        #expect(nextCoups.allSatisfy { $0.expression.type == .question })
        #expect(nextCoups.map(\.prop) == ["-∧2", "-∧1"])
    }

    @Test func reponseAssertionDisjonction() {
        let formuleSimple1 = propositionSimple("P")
        let formuleSimple2 = propositionSimple("Q")
        let formuleComplexe = Proposition(connecteur: .disjonction(formuleSimple1, formuleSimple2))
        let nextCoups = nextCoups(for: formuleComplexe, type: .assertion)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .question)
        #expect(nextCoups[0].prop == "∨?")
    }

    @Test func reponseAssertionImplication() {
        let formuleSimple1 = propositionSimple("P")
        let formuleSimple2 = propositionSimple("Q")
        let formuleComplexe = Proposition(connecteur: .implication(formuleSimple1, formuleSimple2))
        let nextCoups = nextCoups(for: formuleComplexe, type: .assertion)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .assertion)
        #expect(nextCoups[0].prop == "Px")
    }

    @Test func reponseQuestionNegation() {
        let formuleSimple = propositionSimple("P")
        let formuleComplexe = Proposition(connecteur: .negation(formuleSimple))
        let nextCoups = nextCoups(for: formuleComplexe, type: .question)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .assertion)
        #expect(nextCoups[0].prop == "Px")
    }

    @Test func reponseConjonction() {
        let formuleSimple1 = propositionSimple("P")
        let formuleSimple2 = propositionSimple("Q")
        let formuleComplexe = Proposition(connecteur: .conjonction(formuleSimple1, formuleSimple2))
        let nextCoups = nextCoups(for: formuleComplexe, type: .question)

        #expect(nextCoups.count == 2)
        #expect(nextCoups.allSatisfy { $0.isAttaque })
        #expect(nextCoups.allSatisfy { $0.expression.type == .question })
        #expect(nextCoups.map(\.prop) == ["-∧2", "-∧1"])
    }

    @Test func reponseDisjonction() {
        let formuleSimple1 = propositionSimple("P")
        let formuleSimple2 = propositionSimple("Q")
        let formuleComplexe = Proposition(connecteur: .disjonction(formuleSimple1, formuleSimple2))
        let nextCoups = nextCoups(for: formuleComplexe, type: .question)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .question)
        #expect(nextCoups[0].prop == "∨?")
    }

    @Test func reponseImplication() {
        let formuleSimple1 = propositionSimple("P")
        let formuleSimple2 = propositionSimple("Q")
        let formuleComplexe = Proposition(connecteur: .implication(formuleSimple1, formuleSimple2))
        let nextCoups = nextCoups(for: formuleComplexe, type: .question)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .assertion)
        #expect(nextCoups[0].prop == "Px")
    }
}
