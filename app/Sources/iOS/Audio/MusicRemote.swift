import Combine
import MediaPlayer
import UIKit

/// Télécommande de la musique du système : l'app ne diffuse pas de catalogue,
/// elle pilote ce que vous écoutez déjà (Musique, votre bibliothèque).
@MainActor
final class MusicRemote: ObservableObject {
    static let shared = MusicRemote()

    struct NowPlaying: Equatable {
        let title: String
        let artist: String?
        let artwork: UIImage?
    }

    /// URL d'ouverture de l'app Musique, pour choisir un morceau.
    static let musicAppURL = URL(string: "music://")

    @Published private(set) var nowPlaying: NowPlaying?
    @Published private(set) var isPlaying = false
    @Published private(set) var libraryAccess: MPMediaLibraryAuthorizationStatus

    private let player = MPMusicPlayerController.systemMusicPlayer
    private var observers: [NSObjectProtocol] = []

    init() {
        libraryAccess = MPMediaLibrary.authorizationStatus()
    }

    /// Les commandes de lecture fonctionnent sans autorisation ; seul
    /// l'affichage du titre en cours demande l'accès à la bibliothèque.
    var canReadLibrary: Bool { libraryAccess == .authorized }

    func start() {
        guard observers.isEmpty else {
            refresh()
            return
        }

        player.beginGeneratingPlaybackNotifications()
        let center = NotificationCenter.default
        for name in [
            NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange,
            NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange
        ] {
            let observer = center.addObserver(forName: name, object: player, queue: .main) { [weak self] _ in
                Task { @MainActor in self?.refresh() }
            }
            observers.append(observer)
        }
        refresh()
    }

    func requestLibraryAccess() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            Task { @MainActor in
                self?.libraryAccess = status
                self?.refresh()
            }
        }
    }

    func togglePlayPause() {
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
        refresh()
    }

    func next() {
        player.skipToNextItem()
        refresh()
    }

    func previous() {
        // Comportement habituel : on revient au début avant de changer de piste.
        if player.currentPlaybackTime > 3 {
            player.skipToBeginning()
        } else {
            player.skipToPreviousItem()
        }
        refresh()
    }

    private func refresh() {
        isPlaying = player.playbackState == .playing

        guard canReadLibrary, let item = player.nowPlayingItem else {
            nowPlaying = nil
            return
        }
        nowPlaying = NowPlaying(
            title: item.title ?? "Titre inconnu",
            artist: item.artist,
            artwork: item.artwork?.image(at: CGSize(width: 160, height: 160))
        )
    }
}
