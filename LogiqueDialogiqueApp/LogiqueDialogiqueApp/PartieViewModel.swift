import Combine
import Foundation
import LogiqueDialogique

final class PartieViewModel: ObservableObject, Identifiable {
    @Published var partie: Partie
    @Published var isExpanded: Bool = true

    var id: UUID {
        partie.id
    }

    init(partie: Partie) {
        self.partie = partie
    }

    var coupsCount: Int {
        partie.coups.count
    }

    var lignes: [Ligne] {
        partie.lignes
    }
}
