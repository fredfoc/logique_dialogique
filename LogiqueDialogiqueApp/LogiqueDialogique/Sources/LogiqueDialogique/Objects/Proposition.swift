//
//  Proposition.swift
//  LogiqueDialogique
//
//  Created by B054WO on 13/03/2026.
//

import Foundation

public indirect enum Connecteur: CustomStringConvertible, CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case let .conjonction(proposition, proposition2):
            "conjonction"
        case let .conjonctionDroite(proposition, proposition2):
            "attaque Conjonction Droite"
        case let .conjonctionGauche(proposition, proposition2):
            "attaque Conjonction Gauche"
        case let .disjonction(proposition, proposition2):
            "disjonction"
        case let .attaqueDisjonction(proposition, proposition2):
            "attaque Disjonction"
        case let .negation(proposition):
            "negation"
        case let .attaqueNegation(proposition):
            "attaque Negation"
        case let .implication(proposition, proposition2):
            "impliquation"
        case let .attaqueImplication(proposition, proposition2):
            "attaque Implication"
        case let .universel(variable, proposition):
            "universel"
        case let .attaqueUniversel(variable, proposition):
            "attaque Universel"
        case let .existentiel(variable, proposition):
            "existentiel"
        case let .attaqueExistentiel(variable, proposition):
            "attaque Existentiel"
        case .perdu:
            ""
        case .gagne:
            ""
        case let .repetition(int):
            ""
        }
    }

    public var description: String {
        switch self {
        case let .conjonction(proposition1, proposition2):
            return "(\(proposition1.description) ∧ \(proposition2.description))"
        case let .disjonction(proposition1, proposition2):
            return "(\(proposition1.description) ∨ \(proposition2.description))"
        case let .negation(proposition):
            return "(¬" + proposition.description + ")"
        case let .implication(proposition1, proposition2):
            return "(\(proposition1.description) ⇒ \(proposition2.description))"
        case let .universel(variable, proposition):
            if proposition.isSimple {
                return "∀\(variable.name) (\(proposition.description))"
            }
            return "∀\(variable.name) \(proposition.description)"
        case let .existentiel(variable, proposition):
            return "∃\(variable.name) \(proposition.description)"
        case .conjonctionDroite:
            return "-∧2"
        case .conjonctionGauche:
            return "-∧1"
        case let .attaqueUniversel(variable, _):
            return "∀\(variable.name)/\(variable.value ?? "")"
        case let .attaqueImplication(proposition, _):
            return proposition.description
        case .attaqueExistentiel:
            return "∃?"
        case .attaqueDisjonction:
            return "∨?"
        case let .attaqueNegation(proposition):
            return proposition.description
        case .perdu:
            return "perdu"
        case .gagne:
            return "gagné"
        case let .repetition(value):
            return "rg\(value)"
        }
    }

    var evaluation: String {
        switch self {
        case let .attaqueUniversel(_, proposition):
            proposition.description
        case let .attaqueNegation(proposition):
            proposition.description
        case let .conjonctionDroite(_, proposition), let .conjonctionGauche(_, proposition):
            proposition.description
        default:
            description
        }
    }

    case conjonction(Proposition, Proposition)
    case conjonctionDroite(Proposition, Proposition)
    case conjonctionGauche(Proposition, Proposition)
    case disjonction(Proposition, Proposition)
    case attaqueDisjonction(Proposition, Proposition)
    case negation(Proposition)
    case attaqueNegation(Proposition)
    case implication(Proposition, Proposition)
    case attaqueImplication(Proposition, Proposition)
    case universel(Variable, Proposition)
    case attaqueUniversel(Variable, Proposition)
    case existentiel(Variable, Proposition)
    case attaqueExistentiel(Variable, Proposition)
    case perdu
    case gagne
    case repetition(Int)

    func evaluate(_ newVariable: Variable) -> Connecteur {
        switch self {
        case let .conjonction(proposition1, proposition2):
            .conjonction(proposition1.evaluate(newVariable),
                         proposition2.evaluate(newVariable))
        case let .disjonction(proposition1, proposition2):
            .disjonction(proposition1.evaluate(newVariable),
                         proposition2.evaluate(newVariable))
        case let .negation(proposition):
            .negation(proposition.evaluate(newVariable))
        case let .attaqueNegation(proposition):
            .attaqueNegation(proposition.evaluate(newVariable))
        case let .implication(proposition1, proposition2):
            .implication(proposition1.evaluate(newVariable),
                         proposition2.evaluate(newVariable))
        case let .universel(variable, proposition):
            .universel(variable, proposition.evaluate(newVariable))
        case let .existentiel(variable, proposition):
            .existentiel(variable, proposition.evaluate(newVariable))
        case let .conjonctionDroite(proposition, prop):
            .conjonctionDroite(proposition.evaluate(newVariable), prop)
        case let .conjonctionGauche(proposition, prop):
            .conjonctionGauche(proposition.evaluate(newVariable), prop)
        case let .attaqueUniversel(variable, proposition):
            .attaqueUniversel(variable, proposition.evaluate(newVariable))
        case let .attaqueImplication(prop1, prop2):
            .attaqueImplication(prop1.evaluate(newVariable), prop2.evaluate(newVariable))
        case let .attaqueExistentiel(variable, proposition):
            .attaqueExistentiel(variable, proposition.evaluate(newVariable))
        case let .attaqueDisjonction(proposition1, proposition2):
            .attaqueDisjonction(proposition1.evaluate(newVariable),
                                proposition2.evaluate(newVariable))
        case .perdu:
            .perdu
        case .gagne:
            .gagne
        case let .repetition(value):
            .repetition(value)
        }
    }

    var isQuantifier: Bool {
        switch self {
        case .universel, .existentiel:
            true
        default:
            false
        }
    }

    var isUniversel: Bool {
        switch self {
        case .universel:
            true
        default:
            false
        }
    }

    var isExistentiel: Bool {
        switch self {
        case .existentiel:
            true
        default:
            false
        }
    }

    var variable: Variable? {
        switch self {
        case let .universel(variable, _), let .existentiel(variable, _):
            variable
        default:
            nil
        }
    }

    var question: String {
        switch self {
        case .attaqueImplication, .attaqueExistentiel, .attaqueDisjonction, .attaqueNegation:
            ""
        default:
            "?"
        }
    }

    var displayStep: Bool {
        switch self {
        case .perdu, .gagne, .repetition:
            false
        default:
            true
        }
    }
}

public struct Variable {
    let name: String
    let value: String?

    public init(name: String, value: String? = nil) {
        self.name = name
        self.value = value
    }
}

public struct Proposition: CustomStringConvertible, Identifiable, Equatable, CustomDebugStringConvertible {
    public var debugDescription: String {
        if let connecteur = connecteur {
            return "\(connecteur.debugDescription)"
        }
        return description
    }

    public static func == (lhs: Proposition, rhs: Proposition) -> Bool {
        lhs.description == rhs.description
    }

    public let id = UUID()
    public var description: String {
        if let connecteur = connecteur {
            return connecteur.description
        }
        guard let name = name,
              let variable = variable
        else {
            return "oups"
        }
        if let value = variable.value {
            return name + value
        }
        return name + variable.name
    }

    var displayStep: Bool {
        guard let connecteur else {
            return true
        }
        return connecteur.displayStep
    }

    var evaluation: String {
        if let connecteur = connecteur {
            return connecteur.evaluation
        }
        return description
    }

    let name: String?
    let variable: Variable?
    let connecteur: Connecteur?

    public init(name: String? = nil,
                variable: Variable? = nil,
                connecteur: Connecteur? = nil)
    {
        self.name = name
        self.variable = variable
        self.connecteur = connecteur
    }

    var isSimple: Bool {
        guard let connecteur else {
            return true
        }
        switch connecteur {
        case let .attaqueNegation(proposition):
            return proposition.isSimple
        case let .attaqueImplication(antecedent, _):
            return antecedent.isSimple
        default:
            return false
        }
    }

    var isPerdu: Bool {
        guard let connecteur else {
            return true
        }
        switch connecteur {
        case .perdu:
            return true
        default:
            return false
        }
    }

    var isGagnant: Bool {
        !isPerdu
    }

    var isDefinie: Bool {
        guard let variable = variable
        else {
            return false
        }
        return variable.value != nil
    }

    var isSimpleEtDefinie: Bool {
        isSimple && isDefinie
    }

    func evaluate(_ newVariable: Variable) -> Proposition {
        if isSimple {
            guard let variable,
                  variable.name == newVariable.name
            else {
                return self
            }
            return Proposition(name: name, variable: newVariable)
        } else {
            return Proposition(name: name, variable: nil, connecteur: connecteur?.evaluate(newVariable))
        }
    }

    var isUniversel: Bool {
        guard let connecteur else {
            return false
        }
        return connecteur.isUniversel
    }

    var isExistentiel: Bool {
        guard let connecteur else {
            return false
        }
        return connecteur.isExistentiel
    }

    var isQuantifier: Bool {
        guard let connecteur else {
            return false
        }
        return connecteur.isQuantifier
    }
}
