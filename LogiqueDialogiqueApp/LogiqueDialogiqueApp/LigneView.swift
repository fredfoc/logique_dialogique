//
//  LigneView.swift
//  LogiqueDialogiqueApp
//
//  Created by B054WO on 19/03/2026.
//

import LogiqueDialogique
import SwiftUI

struct LigneView: View {
    let ligne: Ligne
    var body: some View {
        HStack(alignment: .top) {
            // Left column (or placeholder)
            Group {
                if let coup1 = ligne.coup1 {
                    CoupView(coup: coup1)
                } else {
                    // Invisible placeholder to keep layout consistent
                    Color.clear
                }
            }
            .frame(maxWidth: 500)

            // vertical divider always shown
            Rectangle()
                .fill(Color(UIColor.separator))
                .frame(width: 1)
                .padding(.vertical, 2)

            // Right column (or placeholder)
            Group {
                if let coup2 = ligne.coup2 {
                    CoupView(coup: coup2)
                } else {
                    Color.clear
                }
            }
            .frame(maxWidth: 500)
        }
    }
}
