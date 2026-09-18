import Foundation

/// Instantané complet de l'état persistant, partagé entre l'app, les widgets et
/// la Watch (fichier JSON dans le conteneur App Group).
public struct SessionState: Codable, Hashable, Sendable {
    public var sessions: [ToiletSession]
    public var active: ToiletSession?
    public var updatedAt: Date

    public init(sessions: [ToiletSession] = [], active: ToiletSession? = nil, updatedAt: Date = Date()) {
        self.sessions = sessions
        self.active = active
        self.updatedAt = updatedAt
    }

    public static let empty = SessionState(sessions: [], active: nil, updatedAt: .distantPast)
}

/// Lecture/écriture synchrone de l'état. Volontairement sans `@MainActor` pour
/// rester utilisable depuis un `TimelineProvider` de widget.
public struct SessionStorage: Sendable {
    public static let shared = SessionStorage()

    private let fileURL: URL

    public init(fileURL: URL = AppGroup.containerURL.appendingPathComponent("sessions.json")) {
        self.fileURL = fileURL
    }

    private static var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }

    private static var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    public func load() -> SessionState {
        guard let data = try? Data(contentsOf: fileURL) else { return .empty }
        return (try? Self.decoder.decode(SessionState.self, from: data)) ?? .empty
    }

    public func save(_ state: SessionState) {
        guard let data = try? Self.encoder.encode(state) else { return }
        let directory = fileURL.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try? data.write(to: fileURL, options: .atomic)
    }

    // MARK: - Encodage pour la synchronisation Watch <-> iPhone

    public static func encode(_ state: SessionState) -> Data? {
        try? encoder.encode(state)
    }

    public static func decode(_ data: Data) -> SessionState? {
        try? decoder.decode(SessionState.self, from: data)
    }
}
