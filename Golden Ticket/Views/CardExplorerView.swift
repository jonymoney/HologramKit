import SwiftUI

struct CardExplorerView: View {
    @State private var config = CardConfiguration()
    @State private var motionManager = MotionManager()
    @State private var presetStore = PresetStore()
    @State private var showControlPanel = false
    @State private var isExploded = false

    var body: some View {
        ZStack {
            config.backgroundColor.ignoresSafeArea()

            HolographicCardView(config: config, motionManager: motionManager, isExploded: isExploded)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let x = Float(value.translation.width / 150)
                    let y = Float(value.translation.height / 150)
                    motionManager.updateSimulatedTilt(x: x, y: y)
                }
                .onEnded { _ in
                    motionManager.updateSimulatedTilt(x: 0, y: 0)
                }
        )
        .overlay(alignment: .topLeading) {
            Button {
                withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                    isExploded.toggle()
                }
            } label: {
                Image(systemName: isExploded ? "square.3.layers.3d.top.filled" : "square.3.layers.3d")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showControlPanel.toggle()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.title2)
                    .foregroundStyle(.primary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .padding()
        }
        .sheet(isPresented: $showControlPanel) {
            ControlPanelView(config: config, presetStore: presetStore)
                .presentationDetents([.medium, .large])
        }
        .onAppear {
            motionManager.sensitivity = config.sensitivity
            motionManager.smoothingFactor = config.smoothingFactor
            motionManager.start()
        }
        .onChange(of: config.sensitivity) { _, val in
            motionManager.sensitivity = val
        }
        .onChange(of: config.smoothingFactor) { _, val in
            motionManager.smoothingFactor = val
        }
    }
}
