//
//  RulesTests.swift
//  LogiqueDialogique
//
//  Created by B054WO on 13/03/2026.
//

@testable import LogiqueDialogique
import Testing

struct Test {
    @Test func reponseAssertionNegation() {
        let formuleSimple = Proposition(name: "P",
                                        variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .negation(formuleSimple))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .assertion,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseAssertionConjonction() {
        let formuleSimple1 = Proposition(name: "P",
                                         variable: Variable(name: "x"))
        let formuleSimple2 = Proposition(name: "Q",
                                         variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .conjonction(formuleSimple1, formuleSimple2, .droite))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .assertion,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseAssertionDisjonction() {
        let formuleSimple1 = Proposition(name: "P",
                                         variable: Variable(name: "x"))
        let formuleSimple2 = Proposition(name: "Q",
                                         variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .disjonction(formuleSimple1, formuleSimple2))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .assertion,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseAssertionImplication() {
        let formuleSimple1 = Proposition(name: "P",
                                         variable: Variable(name: "x"))
        let formuleSimple2 = Proposition(name: "Q",
                                         variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .implication(formuleSimple1, formuleSimple2))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .assertion,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseQuestionNegation() {
        let formuleSimple = Proposition(name: "P",
                                        variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .negation(formuleSimple))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .question,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseConjonction() {
        let formuleSimple1 = Proposition(name: "P",
                                         variable: Variable(name: "x"))
        let formuleSimple2 = Proposition(name: "Q",
                                         variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .conjonction(formuleSimple1, formuleSimple2, .droite))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .question,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseDisjonction() {
        let formuleSimple1 = Proposition(name: "P",
                                         variable: Variable(name: "x"))
        let formuleSimple2 = Proposition(name: "Q",
                                         variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .disjonction(formuleSimple1, formuleSimple2))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .question,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }

    @Test func reponseImplication() {
        let formuleSimple1 = Proposition(name: "P",
                                         variable: Variable(name: "x"))
        let formuleSimple2 = Proposition(name: "Q",
                                         variable: Variable(name: "x"))
        let formuleComplexe = Proposition(connecteur: .implication(formuleSimple1, formuleSimple2))
        let coup = CoupImpl(step: 0,
                            joueur: .Proposant,
                            expression: .question,
                            proposition: formuleComplexe)
        let partie = Partie(index: 0)
        let nextCoup = Rules.evaluateCoup(coup, partie: partie)
        print(coup.description)
        print(nextCoup)
    }
}
