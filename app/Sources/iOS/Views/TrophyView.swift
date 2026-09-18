import SwiftUI

/// Palmarès : hauts faits, équivalences absurdes et certificat partageable.
struct TrophyView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var certificate: Image?

    private var unlocked: [Achievement] {
        AchievementEngine.unlocked(sessions: store.sessions)
    }

    private var stats: Stats { store.stats }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                rankHeader
                badges
                absurdStats
                certificateSection
            }
            .padding(20)
        }
        .navigationTitle("Palmarès")
    }

    // MARK: - Rang

    private var rankHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AchievementEngine.rank(unlockedCount: unlocked.count))
                .font(.title2.weight(.bold))
            Text("\(unlocked.count) haut\(unlocked.count > 1 ? "s" : "") fait\(unlocked.count > 1 ? "s" : "") sur \(Achievement.allCases.count)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            ProgressView(value: Double(unlocked.count), total: Double(Achievement.allCases.count))
                .tint(WCTheme.accent)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(WCTheme.gradient.opacity(0.14), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Hauts faits

    private var badges: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hauts faits")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(spacing: 12), count: 2), spacing: 12) {
                ForEach(Achievement.allCases) { achievement in
                    let isUnlocked = unlocked.contains(achievement)
                    VStack(alignment: .leading, spacing: 6) {
                        Image(systemName: isUnlocked ? achievement.symbol : "lock.fill")
                            .font(.title3)
                            .foregroundStyle(isUnlocked ? WCTheme.warn : Color.secondary)
                        Text(achievement.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(isUnlocked ? .primary : .secondary)
                        Text(achievement.detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(3, reservesSpace: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(
                        isUnlocked ? WCTheme.warn.opacity(0.12) : Color.clear,
                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                    )
                    .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .opacity(isUnlocked ? 1 : 0.65)
                }
            }
        }
    }

    // MARK: - Chiffres absurdes

    private var absurdStats: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Chiffres absurdes")
                .font(.headline)
            Text(AbsurdStats.headline(totalDuration: stats.totalDuration))
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(AbsurdStats.equivalences(totalDuration: stats.totalDuration, visitCount: stats.total)) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.symbol)
                        .font(.footnote)
                        .foregroundStyle(WCTheme.accent)
                        .frame(width: 22)
                    Text(item.value)
                        .font(.body.weight(.semibold))
                        .monospacedDigit()
                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 5)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    // MARK: - Certificat

    private var certificateSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Certificat officiel")
                .font(.headline)
            Text("Une image à faire circuler auprès de gens qui ne l'ont pas demandée.")
                .font(.caption)
                .foregroundStyle(.secondary)

            CertificateCard(
                rank: AchievementEngine.rank(unlockedCount: unlocked.count),
                longest: stats.longestDuration,
                total: stats.total,
                badges: unlocked.count
            )

            if let certificate {
                ShareLink(
                    item: certificate,
                    preview: SharePreview("Certificat WC Connect", image: certificate)
                ) {
                    Label("Partager le certificat", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    renderCertificate()
                } label: {
                    Label("Préparer le certificat", systemImage: "wand.and.stars")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    @MainActor
    private func renderCertificate() {
        let renderer = ImageRenderer(
            content: CertificateCard(
                rank: AchievementEngine.rank(unlockedCount: unlocked.count),
                longest: stats.longestDuration,
                total: stats.total,
                badges: unlocked.count
            )
            .frame(width: 340)
        )
        renderer.scale = 3
        if let image = renderer.uiImage {
            certificate = Image(uiImage: image)
        }
    }
}

/// Le certificat lui-même, également utilisé pour le rendu en image.
struct CertificateCard: View {
    let rank: String
    let longest: TimeInterval
    let total: Int
    let badges: Int

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "rosette")
                .font(.system(size: 34))
                .foregroundStyle(WCTheme.warn)
            Text("Certificat de visite")
                .font(.headline)
            Text(rank)
                .font(.title3.weight(.bold))
                .multilineTextAlignment(.center)

            Divider()

            HStack(spacing: 18) {
                field("Record", WCFormat.duration(longest))
                field("Visites", "\(total)")
                field("Hauts faits", "\(badges)")
            }

            Text("Délivré par WC Connect le \(Date().formatted(date: .abbreviated, time: .omitted)). Sans aucune valeur.")
                .font(.caption2)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(white: 0.99), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(WCTheme.warn.opacity(0.6), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
        )
        .foregroundStyle(.black)
    }

    private func field(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NavigationStack {
        TrophyView().environmentObject(SessionStore.preview)
    }
}
