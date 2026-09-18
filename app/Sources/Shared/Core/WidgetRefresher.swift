#if canImport(WidgetKit)
import WidgetKit
#endif

/// Rafraîchit les widgets après une modification de l'historique.
public enum WidgetRefresher {
    public static func reload() {
        #if canImport(WidgetKit) && !os(macOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
}
