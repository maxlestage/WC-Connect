import AVFoundation
import Foundation

/// Lecture en boucle des ambiances embarquées.
///
/// La session audio est configurée en `mixWithOthers` : l'ambiance se superpose
/// à votre musique au lieu de l'interrompre.
@MainActor
final class SoundscapePlayer: ObservableObject {
    static let shared = SoundscapePlayer()

    @Published private(set) var current: Soundscape?

    @Published var volume: Float {
        didSet {
            player?.volume = volume
            AppGroup.defaults.set(volume, forKey: Self.volumeKey)
        }
    }

    private static let volumeKey = "soundscapeVolume"
    private var player: AVAudioPlayer?
    private var fadeTask: Task<Void, Never>?

    init() {
        let stored = AppGroup.defaults.object(forKey: Self.volumeKey) as? Float
        volume = stored ?? 0.6
    }

    var isPlaying: Bool { current != nil }

    func toggle(_ soundscape: Soundscape) {
        if current == soundscape {
            stop()
        } else {
            play(soundscape)
        }
    }

    func play(_ soundscape: Soundscape) {
        fadeTask?.cancel()
        guard let url = Bundle.main.url(
            forResource: soundscape.resourceName,
            withExtension: soundscape.fileExtension
        ) else {
            current = nil
            return
        }

        activateSession()

        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            newPlayer.numberOfLoops = -1
            newPlayer.volume = 0
            newPlayer.prepareToPlay()
            newPlayer.play()
            newPlayer.setVolume(volume, fadeDuration: 0.6)
            player = newPlayer
            current = soundscape
        } catch {
            player = nil
            current = nil
        }
    }

    func stop() {
        fadeTask?.cancel()
        guard let player else {
            current = nil
            return
        }
        current = nil
        player.setVolume(0, fadeDuration: 0.4)
        fadeTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(450))
            guard !Task.isCancelled else { return }
            player.stop()
            self?.player = nil
            self?.deactivateSession()
        }
    }

    private func activateSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
