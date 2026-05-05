//
//  PartieView.swift
//  LogiqueDialogiqueApp
//
//  Created by B054WO on 19/03/2026.
//

import LogiqueDialogique
import SwiftUI

struct PartieView: View {
    @ObservedObject var viewModel: PartieViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with partie number and coup count, expandable to show lignes
            DisclosureGroup(isExpanded: $viewModel.isExpanded) {
                if viewModel.lignes.isEmpty {
                    Text("No moves")
                        .foregroundColor(.secondary)
                        .accessibilityLabel("No moves available")
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 6) {
                        ForEach(Array(viewModel.lignes.enumerated()), id: \.1.id) { pair in
                            let index = pair.0
                            let ligne = pair.1
                            LigneView(ligne: ligne)
                                .padding(.vertical, 4)
                                .accessibilityElement(children: .contain)
                            if index < viewModel.lignes.count - 1 {
                                Divider()
                                    .padding(.vertical, 2)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Text(viewModel.partie.description)
                        .font(.headline)
                        .accessibilityLabel("Partie")

                    Spacer()

                    // Coup count badge
                    Text("\(viewModel.coupsCount) coups")
                        .font(.caption)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color.accentColor.opacity(0.25), lineWidth: 0.5)
                        )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 0)
        .frame(minHeight: 80)
    }
}
