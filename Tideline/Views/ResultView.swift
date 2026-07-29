import SwiftUI

struct ResultView: View {
    let item: PlasticItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                infoSection(title: "Material / Recycling Code", value: item.materialCode, icon: "number")
                infoSection(title: "Recyclability", value: item.recyclability, icon: "arrow.3.trianglepath")
                infoSection(title: "Reusable Alternative(s)", value: item.alternatives, icon: "leaf.fill")
                infoSection(title: "Where to Get an Alternative", value: item.whereToGetAlternative, icon: "cart.fill")
                infoSection(title: "Plastic Footprint", value: item.plasticFootprint, icon: "chart.bar.fill")
                infoSection(title: "Microplastic Risk", value: item.microplasticRisk, icon: "drop.fill")
                infoSection(title: "Decomposition Time", value: item.decompositionTime, icon: "clock.fill")
                infoSection(title: "Environmental Impact", value: item.environmentalImpact, icon: "globe.americas.fill")
                infoSection(title: "Best Action", value: item.bestAction, icon: "checkmark.seal.fill")
                infoSection(title: "Practical Tip", value: item.practicalTip, icon: "lightbulb.fill")

                acknowledgment
                sourceNote
            }
            .padding()
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.name)
                .font(.title2.bold())
        }
    }

    private func infoSection(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.subheadline.bold())
                .foregroundStyle(.green)
            Text(value.isEmpty ? "Not available" : value)
                .font(.body)
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var acknowledgment: some View {
        Text("Nice work checking that before tossing it!")
            .font(.subheadline.bold())
            .foregroundStyle(.green)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top, 8)
    }

    private var sourceNote: some View {
        Text(item.source == "database" ? "From Tideline's verified database" : "AI-generated estimate")
            .font(.caption)
            .foregroundStyle(.tertiary)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    NavigationStack {
        ResultView(item: PlasticItemLibrary.shared.items.first!)
    }
}
