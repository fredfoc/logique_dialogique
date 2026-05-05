//
//  Parser.swift
//  REPL
//
//  Created by Nick Lockwood on 02/03/2018.
//  Copyright © 2018 Nick Lockwood. All rights reserved.
//

@preconcurrency import Consumer
import Foundation

// MARK: API

public func evaluate(_ input: String) throws -> (assertion: Proposition?, constants: [String]) {
    let match = try proposition.match(input)
    var constants = [String]()
    let proposition = match.transform { name, values in
        switch name {
        case .propositionSimpleDefinie, .propositionSimpleInDefinie:
            return Proposition(name: (values[0] as? String), variable: (values[1] as? Variable))
        case .universel:
            return Proposition(connecteur: .universel((values[0] as! Variable), Proposition(name: "temp")))
        case .existentiel:
            return Proposition(connecteur: .existentiel((values[0] as! Variable), Proposition(name: "temp")))
        case .implication:
            return Proposition(connecteur: .implication((values[0] as! Proposition), (values[1] as! Proposition)))
        case .negation:
            return Proposition(connecteur: .negation((values[0] as! Proposition)))
        case .propositionComplexe:
            switch values.count {
            case 1:
                return values[0] as! Proposition
            default:
                return values.reversed().reduce(nil) { partialResult, proposition -> Proposition? in
                    guard let quantifier = proposition as? Proposition,
                          quantifier.isQuantifier,
                          let variable = quantifier.connecteur?.variable,
                          let partialResult
                    else {
                        return proposition as? Proposition
                    }
                    if quantifier.isExistentiel {
                        return Proposition(connecteur: .existentiel(variable, partialResult))
                    } else if quantifier.isUniversel {
                        return Proposition(connecteur: .universel(variable, partialResult))
                    }
                    return partialResult
                }
            }
        case .variable:
            return Variable(name: values[0] as! String)
        case .constante:
            let value = (values[0] as! String)
            constants.append(value)
            return Variable(name: "constante", value: value)
        case .conjonction:
            return Proposition(connecteur: .conjonction((values[0] as! Proposition), values[1] as! Proposition))
        case .disjonction:
            return Proposition(connecteur: .disjonction((values[0] as! Proposition), (values[1] as! Proposition)))
        }
    }
    return (assertion: (proposition as? [Any])?.first as? Proposition,
            constants: constants)
}

// MARK: Implementation

private enum Label: String {
    case propositionSimpleDefinie
    case propositionSimpleInDefinie
    case universel
    case existentiel
    case implication
    case negation
    case propositionComplexe
    case variable
    case constante
    case conjonction
    case disjonction
}

/// variables
private let variable: Consumer<Label> = .label(.variable, .character(in: "xyz"))

// integer
private let zeroToNine: Consumer<Label> = .character(in: "0" ... "9")
private let oneToNine: Consumer<Label> = .character(in: "1" ... "9")
private let integers: Consumer<Label> = "0" | [oneToNine, .zeroOrMore(zeroToNine)]
private let integer: Consumer<Label> = integers

/// string
private let string: Consumer<Label> = .flatten([
    .discard("\""),
    .zeroOrMore(.any([
        .replace("\\\"", "\""),
        .replace("\\\\", "\\"),
        .replace("\\n", "\n"),
        .replace("\\r", "\r"),
        .replace("\\t", "\t"),
        .discard("\\"),
        .anyCharacter(except: "\"", "\\"),
    ])),
    .discard("\""),
])

// constante
private let lowerAlpha: Consumer<Label> = .character(in: .lowercaseLetters)
private let constante: Consumer<Label> = .label(.constante, .flatten([lowerAlpha, integer]))

// proposition simple indéfinie
private let upperAlpha: Consumer<Label> = .character(in: .uppercaseLetters)
private let propositionSimpleIndefinie: Consumer<Label> = .label(.propositionSimpleInDefinie, [upperAlpha, variable])

/// proposition simple définie
private let propositionSimpleDefinie: Consumer<Label> = .label(.propositionSimpleDefinie, [upperAlpha, constante])

// prop

private let leftParenthesis: Consumer<Label> = .discard("(")
private let rightParenthesis: Consumer<Label> = .discard(")")

private let internalProposition: Consumer<Label> = .any([propositionSimpleDefinie, propositionSimpleIndefinie, .reference(.propositionComplexe)])

/// implication
private let implication: Consumer<Label> = .label(.implication, [internalProposition, .discard("⇒"), internalProposition])

/// implication
private let conjonction: Consumer<Label> = .label(.conjonction, [internalProposition, .discard("∧"), internalProposition])

private let disjonction: Consumer<Label> = .label(.disjonction, [internalProposition, .discard("∨"), internalProposition])

private let negation: Consumer<Label> = .label(.negation, [.discard("¬"), internalProposition])

private let universel: Consumer<Label> = .label(.universel, [.discard("∀"), variable])

private let existentiel: Consumer<Label> = .label(.existentiel, [.discard("∃"), variable])

private let quantifier: Consumer<Label> = .any([universel, existentiel])
private let quantifiedPropositionSimple: Consumer<Label> = [.oneOrMore(quantifier), .any([propositionSimpleDefinie, propositionSimpleIndefinie])]
private let propositionComplexe: Consumer<Label> = .label(.propositionComplexe, [.optional(.oneOrMore(quantifier)), leftParenthesis, .any([negation, implication, conjonction, disjonction, propositionSimpleDefinie, propositionSimpleIndefinie]), rightParenthesis])

// comments and white space
private let space: Consumer<Label> = .character(in: .whitespacesAndNewlines)
private let comment1: Consumer<Label> = ["//", .zeroOrMore(.anyCharacter(except: "\r", "\n"))]
private let comment2: Consumer<Label> = ["/*", .zeroOrMore([.not("*/"), .anyCharacter()]), "*/"]
private let spaceOrComment: Consumer<Label> = .discard(.zeroOrMore(space | comment1 | comment2))

/// root
private let proposition: Consumer<Label> = .ignore(spaceOrComment, in: .any([propositionSimpleDefinie, propositionSimpleIndefinie, propositionComplexe]))
