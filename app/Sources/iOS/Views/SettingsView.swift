import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: SessionStore
    @StateObject private var hydration = HydrationReminders.shared
    @StateObject private var health = HealthExport.shared
    @StateObject private var reminders = VisitReminders.shared

    @State private var goal = WeeklyGoal.stored

    @AppStorage("defaultKind", store: AppGroup.defaults) private var defaultKindRaw = SessionKind.standard.rawValue
    @AppStorage("defaultPlace", store: AppGroup.defaults) private var defaultPlaceRaw = Place.home.rawValue
    @AppStorage("hapticsEnabled", store: AppGroup.defaults) private var hapticsEnabled = true
    @AppStorage("serenityMode", store: AppGroup.defaults) private var serenity = false
    @AppStorage("nightLightEnabled", store: AppGroup.defaults) private var nightLight = false
    @AppStorage("nightLightStartHour", store: AppGroup.defaults) private var nightStart = 22
    @AppStorage("nightLightEndHour", store: AppGroup.defaults) private var nightEnd = 7
    @AppStorage("autoSoundscape", store: AppGroup.defaults) private var autoSoundscapeRaw: String?
    @AppStorage("autoBreathing", store: AppGroup.defaults) private var autoBreathing = false
    @AppStorage("hideGoals", store: AppGroup.defaults) private var hideGoals = false

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
                    Toggle("Mode serein", isOn: $serenity)
                        .onChange(of: serenity) { _, _ in
                            // Une visite déjà lancée doit suivre : sinon
                            // l'écran verrouillé garderait son chronomètre.
                            store.refreshActivity()
                        }
                    Toggle("Veilleuse", isOn: $nightLight)
                    if nightLight {
                        Stepper(value: $nightStart, in: 18...23) {
                            Text("À partir de %@".wcLocalized(WCFormat.hourLabel(nightStart)))
                        }
                        Stepper(value: $nightEnd, in: 4...11) {
                            Text("Jusqu'à %@".wcLocalized(WCFormat.hourLabel(nightEnd)))
                        }
                    }
                    Picker("Ambiance au démarrage", selection: $autoSoundscapeRaw) {
                        Text("Aucune").tag(String?.none)
                        ForEach(Soundscape.allCases) { ambiance in
                            Text(ambiance.title).tag(String?.some(ambiance.rawValue))
                        }
                    }
                    Toggle("Respiration au démarrage", isOn: $autoBreathing)
                    Toggle("Sans objectifs", isOn: $hideGoals)
                } header: {
                    Text("Sérénité")
                } footer: {
                    Text(sereniteFooter)
                }

                Section {
                    Toggle("Rappels d'hydratation", isOn: Binding(
                        get: { hydration.isEnabled },
                        set: { actif in
                            if actif {
                                Task { await hydration.enable() }
                            } else {
                                hydration.isEnabled = false
                            }
                        }
                    ))
                    if hydration.isEnabled {
                        Stepper(
                            value: Binding(get: { hydration.count }, set: { hydration.count = $0 }),
                            in: HydrationSchedule.countRange
                        ) {
                            // Chaînes déjà traduites : l'interpolation d'un
                            // LocalizedStringKey produirait une clé absente
                            // de la table.
                            Text("Rappels par jour : %@".wcLocalized(String(hydration.count)))
                        }
                        Stepper(
                            value: Binding(get: { hydration.startHour }, set: { hydration.startHour = $0 }),
                            in: 5...12
                        ) {
                            Text("À partir de %@".wcLocalized(WCFormat.hourLabel(hydration.startHour)))
                        }
                        Stepper(
                            value: Binding(get: { hydration.endHour }, set: { hydration.endHour = $0 }),
                            in: 15...23
                        ) {
                            Text("Jusqu'à %@".wcLocalized(WCFormat.hourLabel(hydration.endHour)))
                        }
                    }
                } header: {
                    Text("Hydratation")
                } footer: {
                    Text(hydrationFooter)
                }

                Section {
                    Stepper(
                        value: Binding(
                            get: { goal.activeDays },
                            set: { enregistrer(WeeklyGoal(activeDays: $0, maxAverageDuration: goal.maxAverageDuration)) }
                        ),
                        in: 1...7
                    ) {
                        Text("Jours avec visite : %@ sur 7".wcLocalized(String(goal.activeDays)))
                    }
                    Stepper(
                        value: Binding(
                            get: { Int(goal.maxAverageDuration / 60) },
                            set: { enregistrer(WeeklyGoal(activeDays: goal.activeDays, maxAverageDuration: TimeInterval($0) * 60)) }
                        ),
                        in: 2...15
                    ) {
                        Text("Durée moyenne visée : %@ min".wcLocalized(String(Int(goal.maxAverageDuration / 60))))
                    }
                } header: {
                    Text("Objectif de la semaine")
                } footer: {
                    Text("Un objectif modeste : de la régularité, et des visites qui ne s'éternisent pas. L'avancement s'affiche dans les statistiques.")
                }

                Section {
                    Toggle("Rappel de régularité", isOn: Binding(
                        get: { reminders.routineEnabled },
                        set: { actif in
                            if actif {
                                Task { await reminders.enableRoutine(sessions: store.sessions) }
                            } else {
                                reminders.routineEnabled = false
                            }
                        }
                    ))
                    if reminders.routineEnabled {
                        Stepper(
                            value: Binding(
                                get: { reminders.routineHour },
                                set: { reminders.routineHour = $0 }
                            ),
                            in: 5...12
                        ) {
                            Text("Chaque jour à %@".wcLocalized(WCFormat.hourLabel(reminders.routineHour)))
                        }
                    }
                } header: {
                    Text("Régularité")
                } footer: {
                    Text("Y aller à heure fixe est le premier conseil contre la constipation : l'intestin se réveille après un repas. L'heure proposée est celle qui ressort déjà de votre historique.")
                }

                Section {
                    Toggle("Alerte d'absence", isOn: Binding(
                        get: { reminders.absenceEnabled },
                        set: { actif in
                            if actif {
                                Task { await reminders.enableAbsence(sessions: store.sessions) }
                            } else {
                                reminders.absenceEnabled = false
                                Task { await reminders.rescheduleAbsence(sessions: store.sessions) }
                            }
                        }
                    ))
                    if reminders.absenceEnabled {
                        Stepper(
                            value: Binding(
                                get: { reminders.absenceDays },
                                set: { jours in
                                    reminders.absenceDays = jours
                                    Task { await reminders.rescheduleAbsence(sessions: store.sessions) }
                                }
                            ),
                            in: AbsenceEngine.thresholdRange
                        ) {
                            Text("Au-delà de %@".wcLocalized(WCFormat.days(reminders.absenceDays)))
                        }
                    }
                } header: {
                    Text("Absence prolongée")
                } footer: {
                    Text(absenceFooter)
                }

                Section {
                    Toggle("Limiter le temps assis", isOn: Binding(
                        get: { reminders.sittingEnabled },
                        set: { actif in
                            if actif {
                                Task { await reminders.enableSitting() }
                            } else {
                                reminders.sittingEnabled = false
                            }
                        }
                    ))
                    if reminders.sittingEnabled {
                        Stepper(
                            value: Binding(
                                get: { reminders.sittingMinutes },
                                set: { reminders.sittingMinutes = $0 }
                            ),
                            in: VisitReminders.sittingRange
                        ) {
                            Text("Rappel après %@ min".wcLocalized(String(reminders.sittingMinutes)))
                        }
                    }
                } header: {
                    Text("Temps assis")
                } footer: {
                    Text("Rester longtemps assis fatigue les veines, et met la peau sous pression — ce qui compte double quand on ne se lève pas. Le rappel arrive pendant la visite, et disparaît dès qu'elle se termine.")
                }

                Section {
                    LabeledContent("Live Activity", value: liveActivityStatus)
                    LabeledContent("Apple Watch", value: WatchSyncService.shared.isSupported ? "Appairée".wcLocalized : "Indisponible".wcLocalized)
                } header: {
                    Text("Appareils")
                } footer: {
                    Text("La Live Activity s'affiche sur l'écran verrouillé, dans la Dynamic Island et dans la pile intelligente de l'Apple Watch. Elle s'active automatiquement au démarrage d'une visite.")
                }

                Section {
                    Toggle("Exporter les symptômes vers Santé", isOn: Binding(
                        get: { health.isEnabled },
                        set: { actif in
                            if actif {
                                Task { await health.enable() }
                            } else {
                                health.isEnabled = false
                            }
                        }
                    ))
                    .disabled(!health.isAvailable)
                } header: {
                    Text("Santé")
                } footer: {
                    Text(healthFooter)
                }

                Section("Données") {
                    LabeledContent("Visites enregistrées", value: "\(store.sessions.count)")
                    NavigationLink {
                        MedicalReportView()
                    } label: {
                        Label("Bilan pour le médecin", systemImage: "doc.text.magnifyingglass")
                    }
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
            .task {
                await hydration.refreshAuthorization()
            }
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

    /// Pied de la section Hydratation : les heures réellement programmées.
    private var sereniteFooter: String {
        if hideGoals {
            return "Sans objectifs, l'objectif de la semaine et la série de jours disparaissent de l'app. Une série qui se casse fait plus de mal qu'une série qui dure ne fait de bien.".wcLocalized
        }
        if serenity {
            return "Pendant la visite, l'app n'affiche ni chiffre ni objectif : juste un souffle. La durée reste enregistrée pour les statistiques et le bilan médical.".wcLocalized
        }
        return "Le mode serein retire le chronomètre de l'écran et de l'écran verrouillé. Rien n'est perdu : la durée continue d'être enregistrée.".wcLocalized
    }

    private var hydrationFooter: String {
        guard hydration.isEnabled else {
            return "Boire régulièrement est le conseil le plus déterminant, et le plus facile à oublier.".wcLocalized
        }
        let heures = hydration.hours.map(WCFormat.hourLabel).joined(separator: ", ")
        return "Rappels prévus à %@. Tout est programmé localement.".wcLocalized(heures)
    }

    /// Pied de l'alerte d'absence : ce que dit l'historique aujourd'hui.
    private var absenceFooter: String {
        guard reminders.absenceEnabled else {
            return "Trois jours sans selles est le repère usuel de la constipation. L'app le signale une fois, sans dramatiser.".wcLocalized
        }
        guard let jours = AbsenceEngine.daysSinceLastVisit(sessions: store.sessions) else {
            return "Aucune visite enregistrée : l'alerte se programmera après la première.".wcLocalized
        }
        return "Dernière visite il y a %@. L'alerte est programmée en fin d'après-midi.".wcLocalized(WCFormat.days(jours))
    }

    private var healthFooter: String {
        health.isAvailable
            ? "Seuls les symptômes digestifs sont déposés dans Santé : constipation, diarrhée, ballonnements, crampes. Jamais l'historique complet.".wcLocalized
            : "L'app Santé n'est pas disponible sur cet appareil.".wcLocalized
    }

    /// Enregistre l'objectif dans l'espace partagé et rafraîchit l'affichage.
    private func enregistrer(_ nouveau: WeeklyGoal) {
        goal = nouveau
        WeeklyGoal.stored = nouveau
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
