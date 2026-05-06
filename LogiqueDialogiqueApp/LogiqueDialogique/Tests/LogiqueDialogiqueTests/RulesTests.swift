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

    @Test func opposanteHadChoices_detecte_attaque_universel() {
        let inner = Proposition(name: "P", variable: Variable(name: "x"))
        let attackProp = Proposition(connecteur: .attaqueUniversel(Variable(name: "x", value: "c1"), inner))
        let coup = Coup(relatedStep: nil,
                        step: 0,
                        role: .attaque(attackProp),
                        expression: Expression(type: .question, proposition: attackProp, joueur: .Opposante))
        let partie = Partie(index: 0, coups: [coup], constants: [])

        #expect(partie.opposanteHadChoices)
    }

    @Test func opposanteHadChoices_detecte_attaque_attaqueConjonctionDroite() {
        let p1 = Proposition(name: "P", variable: Variable(name: "x"))
        let p2 = Proposition(name: "Q", variable: Variable(name: "x"))
        let attackProp = Proposition(connecteur: .attaqueConjonctionDroite(p1, p2))
        let coup = Coup(relatedStep: nil,
                        step: 0,
                        role: .attaque(attackProp),
                        expression: Expression(type: .question, proposition: attackProp, joueur: .Opposante))
        let partie = Partie(index: 0, coups: [coup], constants: [])

        #expect(partie.opposanteHadChoices)
    }

    @Test func opposanteHadChoices_detecte_attaque_attaqueConjonctionGauche() {
        let p1 = Proposition(name: "P", variable: Variable(name: "x"))
        let p2 = Proposition(name: "Q", variable: Variable(name: "x"))
        let attackProp = Proposition(connecteur: .attaqueConjonctionGauche(p1, p2))
        let coup = Coup(relatedStep: nil,
                        step: 0,
                        role: .attaque(attackProp),
                        expression: Expression(type: .question, proposition: attackProp, joueur: .Opposante))
        let partie = Partie(index: 0, coups: [coup], constants: [])

        #expect(partie.opposanteHadChoices)
    }

    @Test func opposanteHadChoices_detecte_defense_existentiel_et_disjonction() {
        // attaque existentiel puis defense par opposante
        let inner = Proposition(name: "P", variable: Variable(name: "x"))
        let attack = Proposition(connecteur: .attaqueExistentiel(Variable(name: "x"), inner))
        let attackCoup = Coup(relatedStep: nil,
                              step: 0,
                              role: .attaque(attack),
                              expression: Expression(type: .question, proposition: attack, joueur: .Proposant))
        let defenseCoup = Coup(relatedStep: 0,
                               step: 1,
                               role: .defense(attack),
                               expression: Expression(type: .assertion, proposition: inner, joueur: .Opposante))

        let partie1 = Partie(index: 0, coups: [attackCoup, defenseCoup], constants: [])
        #expect(partie1.opposanteHadChoices)

        // attaque disjonction puis defense par opposante
        let p1 = Proposition(name: "P", variable: Variable(name: "x"))
        let p2 = Proposition(name: "Q", variable: Variable(name: "x"))
        let attack2 = Proposition(connecteur: .attaqueDisjonction(p1, p2))
        let attackCoup2 = Coup(relatedStep: nil,
                               step: 0,
                               role: .attaque(attack2),
                               expression: Expression(type: .question, proposition: attack2, joueur: .Proposant))
        let defenseCoup2 = Coup(relatedStep: 0,
                                step: 1,
                                role: .defense(attack2),
                                expression: Expression(type: .assertion, proposition: p1, joueur: .Opposante))

        let partie2 = Partie(index: 0, coups: [attackCoup2, defenseCoup2], constants: [])
        #expect(partie2.opposanteHadChoices)
    }

    @Test func opposanteHadChoices_false_quand_aucun_choice() {
        // Opposante n'a que des affirmations simples -> pas de choix
        let prop = Proposition(name: "P", variable: Variable(name: "x"))
        let coup = Coup(relatedStep: nil,
                        step: 0,
                        role: .unknown,
                        expression: Expression(type: .assertion, proposition: prop, joueur: .Opposante))
        let partie = Partie(index: 0, coups: [coup], constants: [])

        #expect(!partie.opposanteHadChoices)
    }

    @Test func dialogue_hasStrategie_condition1() throws {
        // partie gagnée par le proposant et opposante n'a aucun choix
        let dialogue = try Dialogue(assertion: "((Pc1 ⇒ Qc1) ⇒ ((¬(Qc1)) ⇒ (¬(Pc1))))")
        #expect(dialogue.hasStrategie)
    }

    @Test func dialogue_hasStrategie_condition2() throws {
        // toutes les parties où l'opposante a un choix sont gagnées par le proposant
        let dialogue = try Dialogue(assertion: "∀x ((Px ⇒ Qc1) ⇒ ((¬(Qc1)) ⇒ (¬(Px))))")
        #expect(dialogue.hasStrategie)
    }

    @Test func dialogue_hasStrategie_false_when_opposante_has_choice_and_proposant_loses() throws {
        // partie où l'opposante a un choix mais le proposant ne gagne -> pas de stratégie
        let dialogue = try Dialogue(assertion: "(Pc1 ⇒ Qc1)")
        #expect(!dialogue.hasStrategie)
    }

    @Test func dialogue_parties_condition1() throws {
        // partie gagnée par le proposant et opposante n'a aucun choix
        let dialogue = try Dialogue(assertion: "((Pc1 ∧ Qc1) ⇒ Qc1)")
        #expect(dialogue.hasStrategie)
        #expect(dialogue.parties.count == 1)
    }

    @Test func dialogue_parties_condition2() throws {
        let dialogue = try Dialogue(assertion: "(∀x (Px ∧ Qx) ⇒ (Qc1 ∧ Pc1))")
        #expect(dialogue.parties.count > 1)
    }
}
