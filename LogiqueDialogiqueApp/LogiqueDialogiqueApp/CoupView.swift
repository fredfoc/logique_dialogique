//
//  CoupView.swift
//  LogiqueDialogiqueApp
//
//  Created by B054WO on 19/03/2026.
//

import LogiqueDialogique
import SwiftUI

struct CoupView: View {
    let coup: Coup
    var body: some View {
        if coup.isOpposante {
            HStack(alignment: .top) {
                if coup.displayStep {
                    Text("\(coup.step)")
                }

                VStack(alignment: .leading) {
                    if coup.isResultat {
                        // make 'gagné' and 'perdu' bold
                        if coup.isResultat {
                            Text(coup.display).bold()
                        } else {
                            Text(coup.display)
                        }
                    } else {
                        Text(coup.display)
                    }
                    Text(coup.debug).font(.system(size: 10))
                    // Text(coup.debugExpression).font(.system(size: 10))
                }
                Spacer()
                if let relatedStep = coup.relatedStep, coup.displayStep {
                    Text("\(relatedStep)")
                }
            }
        } else {
            HStack(alignment: .top) {
                if let relatedStep = coup.relatedStep, coup.displayStep {
                    Text("\(relatedStep)")
                }
                Spacer()
                VStack(alignment: .leading) {
                    if coup.isResultat {
                        if coup.isResultat {
                            Text(coup.display).bold()
                        } else {
                            Text(coup.display)
                        }
                    } else {
                        Text(coup.display)
                    }
                    Text(coup.debug).font(.system(size: 9))
                    // Text(coup.debugExpression).font(.system(size: 10))
                }
                if coup.displayStep {
                    Text("\(coup.step)")
                }
            }
        }
    }
}
