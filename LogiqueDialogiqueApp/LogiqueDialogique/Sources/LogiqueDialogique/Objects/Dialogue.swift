//
//  Dialogue.swift
//  LogiqueDialogique
//
//  Created by B054WO on 13/03/2026.
//

import Consumer
import Foundation

public class Dialogue: CustomStringConvertible {
    public var description: String {
        guard let assertion else {
            return "no description"
        }
        return assertion.description
    }

    public let assertion: Proposition?
    public var parties: [Partie] = []
    private var constants: [String]

    public init(assertion: String) throws {
        let result = try evaluate(assertion)
        self.assertion = result.assertion
        constants = result.constants
        refresh()
    }

    public func refresh() {
        guard let assertion else {
            return
        }
        var firstCoup = Coup(relatedStep: nil,
                             step: 0,
                             role: .unknown,
                             expression: Expression(type: .assertion,
                                                    proposition: assertion,
                                                    joueur: .Proposant))
        var secondCoup = Coup(relatedStep: nil,
                              step: 1,
                              role: .unknown,
                              expression: Expression(type: .regle,
                                                     proposition: Proposition(connecteur: .repetition(1)),
                                                     joueur: .Opposante))
        var troisiemeCoup = Coup(relatedStep: 1,
                                 step: 2,
                                 role: .unknown,
                                 expression: Expression(type: .regle,
                                                        proposition: Proposition(connecteur: .repetition(2)),
                                                        joueur: .Proposant))
        Rules.dialogue([firstCoup, secondCoup, troisiemeCoup], &parties, constants: constants)
    }

    public var hasStrategie: Bool {
        return parties.filter { !$0.isWinning }.count == 0
    }
}

public class Ligne: Identifiable {
    public let id = UUID()
    public init(coup1: Coup? = nil, coup2: Coup? = nil) {
        self.coup1 = coup1
        self.coup2 = coup2
    }

    public var coup1: Coup?
    public var coup2: Coup?

    func isCoup1(_ coup: Coup?) -> Bool {
        guard let coup else {
            return false
        }
        return coup1?.prop == coup.prop
    }

    func isCoup2(_ coup: Coup?) -> Bool {
        guard let coup else {
            return false
        }
        return coup2?.prop == coup.prop
    }

    func hasCoup(_ coup: Coup?) -> Bool {
        isCoup1(coup) || isCoup2(coup)
    }
}

public class Partie: CustomStringConvertible, Identifiable {
    public let id = UUID()
    public init(index: Int, coups: [Coup] = [], constants: [String]) {
        self.index = index
        self.coups = coups
        self.constants = constants
    }

    let index: Int
    public var description: String {
        "Partie n°\(index)"
    }

    public var coups: [Coup]
    public var lignes: [Ligne] {
        var lignes = [Ligne]()
        var currentCoups = Array(repeating: false, count: coups.count + 1)
        for coup in coups {
            if coup.isAttaque {
                let associatedCoup = associatedAnswer(of: coup)
                if let associatedCoup {
                    currentCoups[associatedCoup.step] = true
                }
                if coup.isOpposante {
                    lignes.append(Ligne(coup1: coup, coup2: associatedCoup))
                } else {
                    lignes.append(Ligne(coup1: associatedCoup, coup2: coup))
                }
            } else if coup.isRegle {
                if !currentCoups[coup.step] {
                    let associatedRegle = associatedRegle(of: coup)
                    if let associatedRegle {
                        currentCoups[associatedRegle.step] = true
                    }
                    if coup.isOpposante {
                        lignes.append(Ligne(coup1: coup, coup2: associatedRegle))
                    } else {
                        lignes.append(Ligne(coup1: associatedRegle, coup2: coup))
                    }
                }
            } else if coup.isResultat {
                if !currentCoups[coup.step] {
                    let associatedResultat = associatedResultat(of: coup)
                    if let associatedResultat {
                        currentCoups[associatedResultat.step] = true
                    }
                    if coup.isOpposante {
                        lignes.append(Ligne(coup1: coup, coup2: associatedResultat))
                    } else {
                        lignes.append(Ligne(coup1: associatedResultat, coup2: coup))
                    }
                }
            } else {
                if !currentCoups[coup.step] {
                    if coup.isOpposante {
                        lignes.append(Ligne(coup1: coup))
                    } else {
                        lignes.append(Ligne(coup2: coup))
                    }
                }
            }
            currentCoups[coup.step] = true
        }
        return lignes
    }

    var constants: [String]

    var nextVariable: String {
        let lastIndex = constants.reduce(0) { max($0, Int($1.dropFirst()) ?? 0) }
        return "c\(lastIndex + 1)"
    }

    var lastVariable: String {
        return constants.last ?? "c1"
    }

    var nextStep: Int {
        coups.count
    }

    func bumpIndexVar() {
        let lastIndex = constants.reduce(0) { max($0, Int($1.dropFirst()) ?? 0) }
        constants.append("c\(lastIndex + 1)")
    }

    var isWinning: Bool {
        coups.filter { $0.isPerdu }.first?.isOpposante ?? false
    }

    func associatedAnswer(of coup: Coup) -> Coup? {
        coups.filter { $0.isDefense }
            .first { $0.relatedStep == coup.step }
    }

    func associatedRegle(of coup: Coup) -> Coup? {
        coups.filter { $0.isRegle }
            .first { $0.relatedStep == coup.step }
    }

    func associatedResultat(of coup: Coup) -> Coup? {
        coups.filter { $0.isResultat }
            .first { $0.relatedStep == coup.step }
    }

    func coup(at step: Int?) -> Coup? {
        guard let step, step < coups.count else {
            return nil
        }
        return coups[step]
    }
}

public enum Rules {
    static func dialogue(_ coups: [Coup], _ parties: inout [Partie], constants: [String]) {
        var partie = Partie(index: parties.count + 1, coups: coups, constants: constants)
        parties.append(partie)
        evaluatePartie(partie, &parties)
    }

    static func newPartie(from partie: Partie, _ coup: Coup, _ parties: inout [Partie]) {
        var partie = Partie(index: parties.count + 1, coups: partie.coups, constants: partie.constants)
        parties.append(partie)
        partie.coups.append(coup)
        if coup.shouldBump {
            partie.bumpIndexVar()
        }
        evaluatePartie(partie, &parties)
    }

    static func evaluatePartie(_ partie: Partie, _ parties: inout [Partie]) {
        var nextCoups = Rules.evaluateCoup(partie: partie)
        while !nextCoups.isEmpty {
            var nextCoup = nextCoups.removeFirst()
            nextCoups.forEach { coup in newPartie(from: partie, coup, &parties) }
            partie.coups.append(nextCoup)
            if nextCoup.shouldBump {
                partie.bumpIndexVar()
            }
            nextCoups = Rules.evaluateCoup(partie: partie)
        }
        if let lastCoup = partie.coups.last {
            partie.coups.append(Coup(relatedStep: nil,
                                     step: partie.coups.count,
                                     role: .unknown,
                                     expression: Expression(type: .resultat,
                                                            proposition: Proposition(connecteur: .gagne),
                                                            joueur: lastCoup.expression.joueur)))
            partie.coups.append(Coup(relatedStep: partie.coups.count - 1,
                                     step: partie.coups.count,
                                     role: .unknown,
                                     expression: Expression(type: .resultat,
                                                            proposition: Proposition(connecteur: .perdu),
                                                            joueur: lastCoup.nextJoueur)))
        }
    }

    static func filterValidCoup(_ isProposant: Bool,
                                coups: [Coup],
                                partie: Partie) -> [Coup]
    {
        guard isProposant else {
            return coups
        }
        let coupsSimplesOpposante = partie.coups.filter { $0.isOpposante && $0.isSimple }
        return coups.compactMap { coup in
            if coup.isComplexe || coupsSimplesOpposante.has(coup) {
                return coup
            }
            return nil
        }
    }

    static func evaluateCoup(partie: Partie) -> [Coup] {
        let coup = partie.coups.last!
        let coups = answer(coup, partie: partie) + attack(coup, partie: partie)
        return filterValidCoup(coup.nextJoueur.isProposant,
                               coups: coups,
                               partie: partie)
    }

    static func answer(_ coup: Coup, partie: Partie) -> [Coup]? {
        guard coup.isAttaque, let propositionComplexe = coup.expression.proposition.connecteur else {
            return nil
        }
        let relatedCoup = partie.coup(at: coup.relatedStep)
        switch propositionComplexe {
        case let .conjonctionDroite(proposition, _), let .conjonctionGauche(proposition, _):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .defense(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: proposition,
                                                joueur: coup.nextJoueur))]
        case let .attaqueDisjonction(prop1, prop2):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .defense(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: prop1,
                                                joueur: coup.nextJoueur)),
                    Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .defense(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: prop2,
                                                joueur: coup.nextJoueur))]
        case let .attaqueExistentiel(variable, proposition):
            let appliedVariable: Variable
            if coup.isOpposante {
                appliedVariable = Variable(name: variable.name, value: partie.lastVariable)
            } else {
                appliedVariable = Variable(name: variable.name, value: partie.nextVariable)
            }

            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .defense(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: proposition.evaluate(appliedVariable),
                                                joueur: coup.nextJoueur))]
        case let .attaqueUniversel(variable, proposition):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .defense(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: proposition.evaluate(variable),
                                                joueur: coup.nextJoueur))]
        case let .attaqueImplication(_, consequent):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .defense(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: consequent,
                                                joueur: coup.nextJoueur))]
        case .negation, .implication, .universel, .conjonction, .existentiel, .disjonction, .attaqueNegation, .perdu, .gagne, .repetition:
            return nil
        }
    }

    static func answer(_ coup: Coup, partie: Partie) -> [Coup] {
        var values = partie.coups
            .filter { $0.isSameJoueur(coup.expression.joueur) }
            .compactMap { answer($0, partie: partie) }
            .flatMap { $0 }
            .filter { !partie.coups.contains($0) }
        return values ?? [Coup]()
    }

    static func attack(_ coup: Coup, partie: Partie) -> [Coup]? {
        guard let propositionComplexe = coup.expression.proposition.connecteur else {
            return nil
        }
        switch propositionComplexe {
        case let .conjonction(prop1, prop2):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .question,
                                                proposition: Proposition(connecteur: .conjonctionDroite(prop2, coup.expression.proposition)),
                                                joueur: coup.nextJoueur)),
                    Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .question,
                                                proposition: Proposition(connecteur: .conjonctionGauche(prop1, coup.expression.proposition)),
                                                joueur: coup.nextJoueur))]
        case let .disjonction(prop1, prop2):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .question,
                                                proposition: Proposition(connecteur: .attaqueDisjonction(prop1, prop2)),
                                                joueur: coup.nextJoueur))]
        case let .negation(proposition):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: Proposition(connecteur: .attaqueNegation(proposition)),
                                                joueur: coup.nextJoueur))]
        case let .existentiel(variable, proposition):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .question,
                                                proposition: Proposition(connecteur: .attaqueExistentiel(variable, proposition)),
                                                joueur: coup.nextJoueur))]
        case let .implication(antecedent, consequent):
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .assertion,
                                                proposition: Proposition(connecteur: .attaqueImplication(antecedent, consequent)),
                                                joueur: coup.nextJoueur))]
        case let .universel(variable, proposition):
            let appliedVariable: Variable
            if coup.isOpposante {
                appliedVariable = Variable(name: variable.name, value: partie.lastVariable)
            } else {
                appliedVariable = Variable(name: variable.name, value: partie.nextVariable)
            }
            
            return [Coup(relatedStep: coup.step,
                         step: partie.nextStep,
                         role: .attaque(coup.expression.proposition),
                         expression: Expression(type: .question,
                                                proposition: Proposition(connecteur: .attaqueUniversel(appliedVariable, proposition)),
                                                joueur: coup.nextJoueur))]
        case let .attaqueImplication(proposition, _),
            let .attaqueNegation(proposition):
            return attack(coup.copy(proposition: proposition), partie: partie)
        case .attaqueUniversel, .conjonctionDroite, .conjonctionGauche, .attaqueExistentiel, .attaqueDisjonction, .perdu, .gagne, .repetition:
            return nil
        }
        return nil
    }

    static func attack(_ coup: Coup, partie: Partie) -> [Coup] {
        var values = partie.coups
            .filter { $0.isSameJoueur(coup.expression.joueur) }
            .compactMap { attack($0, partie: partie) }
            .flatMap { $0 }
            .filter { !partie.coups.contains($0) }
        return values ?? [Coup]()
    }
}

extension Array where Element == Coup {
    func has(_ coup: Coup) -> Bool {
        first { element in
            element.expression.proposition.evaluation == coup.expression.proposition.evaluation
        } != nil
    }
}
