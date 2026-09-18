import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: SessionStore

    @AppStorage("defaultKind", store: AppGroup.defaults) private var defaultKindRaw = SessionKind.standard.rawValue
    @AppStorage("defaultPlace", store: AppGroup.defaults) private var defaultPlaceRaw = Place.home.rawValue
    @AppStorage("hapticsEnabled", store: AppGroup.defaults) private var hapticsEnabled = true

    @State private var showResetConfirmation = false
    @State private var exportedCSV: String?

    var body: some View {
        NavigationStack {
            Form {
                Section("Par défaut") {
                    Picker("Type de visite", selection: $defaultKindRaw) {
                        ForEach(SessionKind.allCases, id: \.rawValue) { kind in
                            Text(kind.title).tag(kind.rawValue)
                        }
                    }
                    Picker("Lieu", selection: $defaultPlaceRaw) {
                        ForEach(Place.allCases, id: \.rawValue) { place in
                            Text(place.title).tag(place.rawValue)
                        }
                    }
                    Toggle("Retour haptique sur la Watch", isOn: $hapticsEnabled)
                }

                Section {
                    LabeledContent("Live Activity", value: liveActivityStatus)
                    LabeledContent("Apple Watch", value: WatchSyncService.shared.isSupported ? "Appairée".wcLocalized : "Indisponible".wcLocalized)
                } header: {
                    Text("Appareils")
                } footer: {
                    Text("La Live Activity s'affiche sur l'écran verrouillé, dans la Dynamic Island et dans la pile intelligente de l'Apple Watch. Elle s'active automatiquement au démarrage d'une visite.")
                }

                Section("Données") {
                    LabeledContent("Visites enregistrées", value: "\(store.sessions.count)")
                    Button {
                        exportedCSV = store.exportCSV()
                    } label: {
                        Label("Exporter en CSV", systemImage: "square.and.arrow.up")
                    }
                    Button(role: .destructive) {
                        showResetConfirmation = true
                    } label: {
                        Label("Effacer l'historique", systemImage: "trash")
                    }
                }

                Section {
                    LabeledContent("Version", value: appVersion)
                    LabeledContent("Conçu et développé par", value: "Maxime Nathan Lestage")
                } header: {
                    Text("Crédits")
                } footer: {
                    Text("Toutes les données restent sur vos appareils : stockage local partagé entre l'app, les widgets et la Watch. Aucun compte, aucun serveur.")
                }
            }
            .navigationTitle("Réglages")
            .confirmationDialog(
                "Effacer tout l'historique ?",
                isPresented: $showResetConfirmation,
                titleVisibility: .visible
            ) {
                Button("Effacer", role: .destructive) { store.removeAll() }
                Button("Annuler", role: .cancel) {}
            } message: {
                Text("Cette action est définitive.")
            }
            .sheet(isPresented: Binding(get: { exportedCSV != nil }, set: { if !$0 { exportedCSV = nil } })) {
                if let csv = exportedCSV {
                    ShareLink(item: csv, preview: SharePreview("visites-wc-connect.csv")) {
                        Label("Partager le CSV", systemImage: "square.and.arrow.up")
                    }
                    .padding()
                    .presentationDetents([.height(160)])
                }
            }
        }
    }

    private var liveActivityStatus: String {
        LiveActivityController.shared.isAvailable ? "Autorisée".wcLocalized : "Désactivée dans Réglages".wcLocalized
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView().environmentObject(SessionStore.preview)
}
