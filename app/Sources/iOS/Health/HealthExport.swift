import Foundation
#if canImport(HealthKit)
import HealthKit
#endif

/// Export des symptômes vers l'app Santé.
///
/// HealthKit ne sait pas enregistrer une visite, mais il connaît les symptômes
/// digestifs : constipation, diarrhée, ballonnements, crampes abdominales.
/// C'est ce que l'app y dépose, et rien d'autre — jamais l'historique complet.
@MainActor
final class HealthExport: ObservableObject {
    static let shared = HealthExport()

    private enum Key {
        static let enabled = "healthExportEnabled"
    }

    @Published var isEnabled: Bool {
        didSet { AppGroup.defaults.set(isEnabled, forKey: Key.enabled) }
    }

    init() {
        isEnabled = AppGroup.defaults.bool(forKey: Key.enabled)
    }

    #if canImport(HealthKit)
    private let store = HKHealthStore()

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    /// Types écrits par l'app, et eux seuls.
    private var writtenTypes: Set<HKSampleType> {
        let identifiants: [HKCategoryTypeIdentifier] = [
            .constipation, .diarrhea, .bloating, .abdominalCramps
        ]
        let types: [HKSampleType] = identifiants.compactMap {
            HKObjectType.categoryType(forIdentifier: $0)
        }
        return Set(types)
    }

    /// Demande l'autorisation d'écriture, puis mémorise le choix.
    func enable() async {
        guard isAvailable else {
            isEnabled = false
            return
        }
        do {
            try await store.requestAuthorization(toShare: writtenTypes, read: [])
            isEnabled = true
        } catch {
            isEnabled = false
        }
    }

    /// Dépose les symptômes d'une visite terminée.
    func export(_ session: ToiletSession) async {
        guard isEnabled, isAvailable, let fin = session.endedAt else { return }

        var echantillons: [HKCategorySample] = []

        // La consistance renseigne la constipation ou la diarrhée.
        if let tendance = session.bristol?.tendency {
            switch tendance {
            case .constipation:
                echantillons += sample(.constipation, from: session.startedAt, to: fin)
            case .loose:
                echantillons += sample(.diarrhea, from: session.startedAt, to: fin)
            case .ideal:
                break
            }
        }

        for symptome in session.symptomList {
            switch symptome {
            case .bloating:
                echantillons += sample(.bloating, from: session.startedAt, to: fin)
            case .cramps:
                echantillons += sample(.abdominalCramps, from: session.startedAt, to: fin)
            default:
                break
            }
        }

        guard !echantillons.isEmpty else { return }
        try? await store.save(echantillons)
    }

    private func sample(
        _ identifiant: HKCategoryTypeIdentifier,
        from debut: Date,
        to fin: Date
    ) -> [HKCategorySample] {
        guard let type = HKObjectType.categoryType(forIdentifier: identifiant) else { return [] }
        // Ces types attendent une gravité. L'app ne la demande pas : elle note
        // la présence du symptôme, sans prétendre la mesurer.
        return [
            HKCategorySample(
                type: type,
                value: HKCategoryValueSeverity.unspecified.rawValue,
                start: debut,
                end: fin
            )
        ]
    }
    #else
    var isAvailable: Bool { false }
    func enable() async { isEnabled = false }
    func export(_ session: ToiletSession) async {}
    #endif
}
