import SwiftUI

/// Conseils pour les visites difficiles, et signaux qui doivent envoyer
/// consulter plutôt que persévérer.
struct TipsView: View {
    var body: some View {
        List {
            Section {
                ForEach(TipLibrary.immediate) { tip in
                    TipRow(tip: tip)
                }
            } header: {
                Text("Dans l'instant")
            } footer: {
                Text("Ces gestes-là s'appliquent tout de suite, assis.")
            }

            ForEach(TipCategory.allCases) { category in
                let tips = TipLibrary.tips(for: category).filter { !$0.isImmediate }
                if !tips.isEmpty {
                    Section {
                        ForEach(tips) { tip in
                            TipRow(tip: tip)
                        }
                    } header: {
                        Label(category.title, systemImage: category.symbol)
                    }
                }
            }

            Section {
                ForEach(TipLibrary.redFlags, id: \.self) { flag in
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(WCTheme.warn)
                            .font(.footnote)
                        Text(flag)
                            .font(.subheadline)
                    }
                }
            } header: {
                Text("Quand consulter")
            } footer: {
                Text(TipLibrary.disclaimer)
            }
        }
        .navigationTitle("Conseils")
    }
}

struct TipRow: View {
    let tip: Tip

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label {
                Text(tip.title)
                    .font(.subheadline.weight(.semibold))
            } icon: {
                Image(systemName: tip.category.symbol)
                    .foregroundStyle(WCTheme.accent)
            }
            Text(tip.detail)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        TipsView()
    }
}
