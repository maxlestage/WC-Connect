import SwiftUI

/// Onglet « Détente » : respiration guidée, ambiances sonores et commande de
/// votre musique.
struct RelaxView: View {
    @StateObject private var soundscapes = SoundscapePlayer.shared
    @StateObject private var music = MusicRemote.shared

    @State private var breathing: BreathingPattern?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    breathingSection
                    soundscapeSection
                    musicSection
                    tipsLink
                }
                .padding(20)
            }
            .navigationTitle("Détente")
            .sheet(item: $breathing) { pattern in
                BreathingView(pattern: pattern)
            }
            .task { music.start() }
        }
    }

    // MARK: - Respiration

    private var breathingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Respiration guidée", symbol: "wind")
            Text("Respirer lentement relâche le ventre et le périnée. Ne bloquez jamais votre souffle pour pousser.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            ForEach(BreathingPattern.all) { pattern in
                Button {
                    breathing = pattern
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 8) {
                                Text(pattern.title)
                                    .font(.body.weight(.semibold))
                                if pattern.id == BreathingPattern.belly.id {
                                    Text("conseillé")
                                        .font(.caption2.weight(.semibold))
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(WCTheme.mint.opacity(0.2), in: Capsule())
                                        .foregroundStyle(WCTheme.mint)
                                }
                            }
                            Text(pattern.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 8)
                        Text(WCFormat.duration(pattern.totalDuration))
                            .font(.caption)
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.tertiary)
                    }
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Ambiances

    private var soundscapeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Ambiances", symbol: "speaker.wave.2.fill")
            Text("Boucles embarquées, qui se superposent à votre musique sans l'interrompre.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                ForEach(Soundscape.allCases) { soundscape in
                    let isPlaying = soundscapes.current == soundscape
                    Button {
                        soundscapes.toggle(soundscape)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: isPlaying ? "pause.fill" : soundscape.symbol)
                                .font(.title3)
                            Text(soundscape.title)
                                .font(.caption.weight(.semibold))
                            Text(soundscape.subtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2, reservesSpace: true)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 8)
                        .background(
                            isPlaying ? WCTheme.accent.opacity(0.18) : Color.clear,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(isPlaying ? WCTheme.accent : .clear, lineWidth: 1.5)
                        )
                        .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isPlaying ? "Arrêter \(soundscape.title)" : "Écouter \(soundscape.title)")
                }
            }

            HStack(spacing: 12) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: $soundscapes.volume, in: 0...1)
                    .disabled(!soundscapes.isPlaying)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Musique

    private var musicSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Votre musique", symbol: "music.note")

            if !music.canReadLibrary {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Autorisez l'accès à votre bibliothèque pour voir le morceau en cours. Les commandes de lecture fonctionnent sans autorisation.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Autoriser l'accès") { music.requestLibraryAccess() }
                        .buttonStyle(.bordered)
                }
            }

            if let track = music.nowPlaying {
                HStack(spacing: 12) {
                    artwork(track.artwork)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(track.title)
                            .font(.body.weight(.semibold))
                            .lineLimit(1)
                        if let artist = track.artist {
                            Text(artist)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                    Spacer(minLength: 0)
                }
            } else {
                Text(music.canReadLibrary
                     ? "Rien en cours de lecture. Choisissez un morceau dans Musique, puis revenez ici."
                     : "Lancez un morceau depuis Musique, puis pilotez-le d'ici.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 22) {
                Button { music.previous() } label: {
                    Image(systemName: "backward.fill")
                }
                Button { music.togglePlayPause() } label: {
                    Image(systemName: music.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                Button { music.next() } label: {
                    Image(systemName: "forward.fill")
                }
                Spacer()
                if let url = MusicRemote.musicAppURL {
                    Link(destination: url) {
                        Label("Musique", systemImage: "arrow.up.forward.app")
                            .font(.caption.weight(.semibold))
                    }
                }
            }
            .font(.title3)
            .buttonStyle(.plain)
            .foregroundStyle(WCTheme.accent)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private func artwork(_ image: UIImage?) -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(WCTheme.accent.opacity(0.18))
                .frame(width: 52, height: 52)
                .overlay(Image(systemName: "music.note").foregroundStyle(WCTheme.accent))
        }
    }

    // MARK: - Conseils

    private var tipsLink: some View {
        NavigationLink {
            TipsView()
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "lightbulb.fill")
                    .foregroundStyle(WCTheme.warn)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ça coince ?")
                        .font(.body.weight(.semibold))
                    Text("Posture, respiration, habitudes — et quand consulter.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    private func sectionTitle(_ title: String, symbol: String) -> some View {
        Label(title, systemImage: symbol)
            .font(.headline)
    }
}

#Preview {
    RelaxView()
}
