//
//  Coup.swift
//  LogiqueDialogique
//
//  Created by B054WO on 13/03/2026.
//

import Foundation

public enum Joueur {
    case Opposante
    case Proposant

    var isOpposante: Bool {
        switch self {
        case .Opposante:
            return true
        case .Proposant:
            return false
        }
    }

    var isProposant: Bool {
        !isOpposante
    }
}

public enum Role: Equatable, CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        switch self {
        case let .attaque(prop):
            "attaque: \(prop.description)"
        case let .defense(prop):
            "defense: \(prop.description)"
        case .unknown:
            ""
        }
    }

    public var debugDescription: String {
        description
    }

    case attaque(Proposition)
    case defense(Proposition)
    case unknown

    var isAttack: Bool {
        switch self {
        case .attaque:
            return true
        default:
            return false
        }
    }

    var isDefense: Bool {
        switch self {
        case .defense:
            true
        default:
            false
        }
    }
}

public enum TypeExpression {
    case assertion
    case question
    case regle
    case resultat
}

public struct Expression: Equatable, CustomStringConvertible {
    public var description: String {
        "\(type)-\(proposition.debugDescription)-\(joueur)"
    }

    public static func == (lhs: Expression, rhs: Expression) -> Bool {
        lhs.proposition.evaluation == rhs.proposition.evaluation && lhs.joueur == rhs.joueur && lhs.type == rhs.type
    }

    let type: TypeExpression
    let proposition: Proposition
    let joueur: Joueur
}

public struct Coup: CustomStringConvertible, Identifiable, Equatable {
    public let id: String = UUID().uuidString
    public static func == (lhs: Coup, rhs: Coup) -> Bool {
        lhs.role == rhs.role && lhs.role == rhs.role
    }

    public let relatedStep: Int?
    public let step: Int
    public let role: Role
    public let expression: Expression

    func copy(proposition: Proposition) -> Coup {
        Coup(relatedStep: relatedStep,
             step: step,
             role: role,
             expression: Expression(type: expression.type,
                                    proposition: proposition,
                                    joueur: expression.joueur))
    }
}

public extension Coup {
    var nextJoueur: Joueur {
        switch expression.joueur {
        case .Opposante:
            .Proposant
        case .Proposant:
            .Opposante
        }
    }

    private var relatedStepDescription: String {
        guard let relatedStep else {
            return "-"
        }
        return "\(relatedStep)"
    }

    var debug: String {
        return "\(role.description)"
    }

    var debugExpression: String {
        "\(expression.description)"
    }

    var description: String {
        return "\(step).\(role): \(expression.type) \(prop) (\(relatedStepDescription))"
    }

    var isAttaque: Bool {
        role.isAttack
    }

    var isAttaqueNegation: Bool {
        guard isAttaque, let connecteur = expression.proposition.connecteur else {
            return false
        }
        if case .attaqueNegation = connecteur {
            return true
        }
        return false
    }

    var isRegle: Bool {
        switch expression.type {
        case .regle:
            return true
        default:
            return false
        }
    }

    var isResultat: Bool {
        switch expression.type {
        case .resultat:
            return true
        default:
            return false
        }
    }

    var isPerdu: Bool {
        guard let connecteur = expression.proposition.connecteur else {
            return false
        }
        switch connecteur {
        case .perdu:
            return true
        default:
            return false
        }
    }

    var isDefense: Bool {
        role.isDefense
    }

    var isOpposante: Bool {
        expression.joueur == .Opposante
    }

    var isSimple: Bool {
        expression.proposition.isSimple
    }

    var displayStep: Bool {
        expression.proposition.displayStep
    }

    var isComplexe: Bool {
        !isSimple
    }

    var shouldBump: Bool {
        guard let connecteur = expression.proposition.connecteur else {
            return false
        }
        switch connecteur {
        case .attaqueUniversel:
            return isOpposante
        default:
            return false
        }
    }

    func isNotSameJoueur(_ joueur: Joueur) -> Bool {
        expression.joueur != joueur
    }

    func isSameJoueur(_ joueur: Joueur) -> Bool {
        !isNotSameJoueur(joueur)
    }

    var isProposant: Bool {
        !isOpposante
    }

    var prop: String {
        expression.proposition.description
    }

    var display: String {
        guard let connecteur = expression.proposition.connecteur else {
            return expression.proposition.description
        }
        if isAttaque {
            return connecteur.question + " " + expression.proposition.description
        }
        return expression.proposition.description
    }
}
