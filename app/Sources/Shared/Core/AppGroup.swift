import Foundation

/// Identifiants partagés entre l'app, l'extension de widgets et l'app Watch.
public enum AppGroup {
    /// Doit correspondre à l'App Group configuré dans les entitlements.
    public static let identifier = "group.com.wcconnect.shared"

    /// Répertoire de stockage partagé. Repli sur le sandbox local si l'App Group
    /// n'est pas disponible (ex. simulateur sans provisioning).
    public static var containerURL: URL {
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) {
            return url
        }
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory())
    }

    public static var defaults: UserDefaults {
        UserDefaults(suiteName: identifier) ?? .standard
    }
}
