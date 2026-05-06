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

    @Test func socraticRule_interdit_proposant_assertion_simple_sans_opposante() {
        // Le proposant ne doit pas pouvoir affirmer une proposition simple si l'opposante ne l'a pas déjà affirmée
        let prop = Proposition(name: "P", variable: Variable(name: "x"))
        let expression = Expression(type: .assertion, proposition: prop, joueur: .Proposant)
        let coup = Coup(relatedStep: nil, step: 0, role: .unknown, expression: expression)
        let partie = Partie(index: 0, coups: [], constants: [])

        let valid = Rules.socraticRule(true, coups: [coup], partie: partie)
        #expect(valid.isEmpty)
    }

    @Test func socraticRule_autorise_si_opposante_a_affirme() {
        // Si l'opposante a déjà affirmé la proposition simple, le proposant peut la ré-affirmer
        let prop = Proposition(name: "P", variable: Variable(name: "x"))
        let proposantExpr = Expression(type: .assertion, proposition: prop, joueur: .Proposant)
        let proposantCoup = Coup(relatedStep: nil, step: 1, role: .unknown, expression: proposantExpr)

        let opposanteExpr = Expression(type: .assertion, proposition: prop, joueur: .Opposante)
        let opposanteCoup = Coup(relatedStep: nil, step: 0, role: .unknown, expression: opposanteExpr)

        let partie = Partie(index: 0, coups: [opposanteCoup], constants: [])

        let valid = Rules.socraticRule(true, coups: [proposantCoup], partie: partie)
        #expect(valid.count == 1)
        #expect(valid[0].prop == "Px")
    }

    @Test func regle_opposante_utilise_constante_existante() {
        // Opposante affirme un universel -> l'attaque doit utiliser la dernière constante existante
        let variable = Variable(name: "x")
        let inner = Proposition(name: "P", variable: Variable(name: "x"))
        let universel = Proposition(connecteur: .universel(variable, inner))

        let expression = Expression(type: .assertion, proposition: universel, joueur: .Opposante)
        let coup = Coup(relatedStep: nil, step: 0, role: .unknown, expression: expression)
        let partie = Partie(index: 0, coups: [coup], constants: ["c1", "c2"])

        let nextCoups = Rules.evaluateCoup(partie: partie)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .question)
        #expect(nextCoups[0].prop == "∀x/c2")
    }

    @Test func regle_proposant_introduit_nouvelle_constante() {
        // Proposant affirme un universel -> l'attaque doit utiliser une nouvelle constante (nextVariable)
        let variable = Variable(name: "x")
        let inner = Proposition(name: "P", variable: Variable(name: "x"))
        let universel = Proposition(connecteur: .universel(variable, inner))

        let expression = Expression(type: .assertion, proposition: universel, joueur: .Proposant)
        let coup = Coup(relatedStep: nil, step: 0, role: .unknown, expression: expression)
        let partie = Partie(index: 0, coups: [coup], constants: ["c1", "c2"])

        let nextCoups = Rules.evaluateCoup(partie: partie)

        #expect(nextCoups.count == 1)
        #expect(nextCoups[0].isAttaque)
        #expect(nextCoups[0].expression.type == .question)
        #expect(nextCoups[0].prop == "∀x/c3")
    }
}
