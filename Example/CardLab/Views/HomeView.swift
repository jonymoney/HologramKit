import SwiftUI
import HologramKit

struct HomeView: View {

    private let columns = [
        GridItem(.adaptive(minimum: 160), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 24) {
                    ForEach(SampleCard.catalog) { sample in
                        NavigationLink(value: sample.id) {
                            cardCell(sample)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("CardLab")
            .navigationDestination(for: UUID.self) { id in
                if let sample = SampleCard.catalog.first(where: { $0.id == id }) {
                    CardExplorerView(sample: sample)
                }
            }
        }
    }

    private func cardCell(_ sample: SampleCard) -> some View {
        let scale = 160.0 / sample.cardWidth
        let miniWidth = 160.0
        let miniHeight = sample.cardHeight * scale
        let tallest = SampleCard.catalog.map { $0.cardHeight * (160.0 / $0.cardWidth) }.max() ?? miniHeight

        return VStack(spacing: 12) {
            HologramCard {
                for layer in sample.content(sample.makeDefaultConfig()) {
                    layer
                }
            }
            .cardSize(width: miniWidth, height: miniHeight)
            .hologramCornerRadius(sample.cornerRadius * scale)
            .allowsHitTesting(false)
            .frame(height: tallest, alignment: .bottom)

            VStack(spacing: 2) {
                Text(sample.name)
                    .font(.headline)
                Text(sample.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
