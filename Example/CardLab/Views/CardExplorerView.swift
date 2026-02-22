import SwiftUI
import HologramKit

struct CardExplorerView: View {

    // MARK: - Input

    let sample: SampleCard

    // MARK: - State

    @State private var config: CardConfiguration
    @State private var presetStore = PresetStore()
    @State private var showControlPanel = false
    @State private var isExploded = false

    // MARK: - Init

    init(sample: SampleCard) {
        self.sample = sample
        self._config = State(initialValue: CardConfiguration(
            backgroundColor: sample.backgroundColor,
            cardBaseColor: sample.cardBaseColor,
            cornerRadius: sample.cornerRadius,
            cardWidth: sample.cardWidth,
            cardHeight: sample.cardHeight
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            config.backgroundColor.ignoresSafeArea()

            hologramCard
                .cardSize(width: config.cardWidth, height: config.cardHeight)
                .hologramCornerRadius(config.cornerRadius)
                .tiltIntensity(config.tiltIntensity)
                .parallaxIntensity(config.parallaxIntensity)
                .motionSensitivity(config.sensitivity, smoothing: config.smoothingFactor)
                .hologramInspector(isPresented: $isExploded)
        }
        .navigationTitle(sample.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                        isExploded.toggle()
                    }
                } label: {
                    Image(systemName: isExploded
                          ? "square.3.layers.3d.top.filled"
                          : "square.3.layers.3d")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showControlPanel.toggle()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .sheet(isPresented: $showControlPanel) {
            ControlPanelView(config: config, presetStore: presetStore, customSections: sample.customSections)
                .presentationDetents([.medium, .large])
        }
    }

    // MARK: - Hologram Card

    private var hologramCard: some View {
        HologramCard {
            for layer in sample.content(config) {
                layer
            }
        }
    }
}
