@testable import LogiqueDialogique
import Testing

@Test func traductionFormuleSimpleDefinie() {
    let formuleSimple = Proposition(name: "P",
                                    variable: Variable(name: "x", value: "a"))
    assert(formuleSimple.description == "Pa")
}

@Test func traductionFormuleSimpleIndefinie() {
    let formuleSimple = Proposition(name: "P",
                                    variable: Variable(name: "x"))
    assert(formuleSimple.description == "Px")
}

@Test func traductionFormuleExistentiel() {
    let variable = Variable(name: "x")
    let formuleSimple = Proposition(name: "P",
                                    variable: variable)
    let formuleComplexe = Proposition(connecteur: .existentiel(variable, formuleSimple))
    assert(formuleComplexe.description == "∃x Px")
}

@Test func traductionFormuleUniversel() {
    let variable = Variable(name: "x")
    let formuleSimple = Proposition(name: "P",
                                    variable: variable)
    let formuleComplexe = Proposition(connecteur: .universel(variable, formuleSimple))
    assert(formuleComplexe.description == "∀x Px")
}

@Test func traductionNegation() {
    let formuleSimple = Proposition(name: "P",
                                    variable: Variable(name: "x"))
    let formuleComplexe = Proposition(connecteur: .negation(formuleSimple))
    assert(formuleComplexe.description == "¬Px")
}

@Test func traductionConjonction() {
    let formuleSimple1 = Proposition(name: "P",
                                     variable: Variable(name: "x"))
    let formuleSimple2 = Proposition(name: "Q",
                                     variable: Variable(name: "x"))
    let formuleComplexe = Proposition(connecteur: .conjonction(formuleSimple1, formuleSimple2, .droite))
    assert(formuleComplexe.description == "(Px ∧ Qx)")
}

@Test func traductionDisjonction() {
    let formuleSimple1 = Proposition(name: "P",
                                     variable: Variable(name: "x"))
    let formuleSimple2 = Proposition(name: "Q",
                                     variable: Variable(name: "x"))
    let formuleComplexe = Proposition(connecteur: .disjonction(formuleSimple1, formuleSimple2))
    assert(formuleComplexe.description == "(Px ∨ Qx)")
}

@Test func traductionImplication() {
    let formuleSimple1 = Proposition(name: "P",
                                     variable: Variable(name: "x"))
    let formuleSimple2 = Proposition(name: "Q",
                                     variable: Variable(name: "x"))
    let formuleComplexe = Proposition(connecteur: .implication(formuleSimple1, formuleSimple2))
    assert(formuleComplexe.description == "(Px ⇒ Qx)")
}

@Test func traductionComplexe() {
    let variable = Variable(name: "x")
    let formuleSimple1 = Proposition(name: "P",
                                     variable: variable)
    let formuleSimple2 = Proposition(name: "Q",
                                     variable: variable)
    let implication = Proposition(connecteur: .implication(formuleSimple1, formuleSimple2))
    let existentiel = Proposition(connecteur: .existentiel(variable, implication))
    let formuleComplexe = Proposition(connecteur: .universel(Variable(name: "y"), existentiel))
    assert(formuleComplexe.description == "∀y ∃x (Px ⇒ Qx)")
}
