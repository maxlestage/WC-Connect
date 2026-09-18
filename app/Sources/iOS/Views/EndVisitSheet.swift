import SwiftUI

/// Feuille d'annotation affichée juste après la fin d'une visite : confort,
/// journal (consistance, effort, symptômes), note et haïku.
struct EndVisitSheet: View {
    let session: ToiletSession
    let onSave: (ToiletSession) -> Void

    @Environment(\.dismiss) private var dismiss
    @StateObject private var health = HealthExport.shared

    @State private var comfort: Int
    @State private var bristol: Bristol?
    @State private var effort: Int
    @State private var symptoms: Set<Symptom>
    @State private var note: String

    init(session: ToiletSession, onSave: @escaping (ToiletSession) -> Void) {
        self.session = session
        self.onSave = onSave
        _comfort = State(initialValue: session.comfort ?? 0)
        _bristol = State(initialValue: session.bristol)
        _effort = State(initialValue: session.effort ?? 0)
        _symptoms = State(initialValue: Set(session.symptomList))
        _note = State(initialValue: session.note ?? "")
    }

    private var needsAdvice: Bool {
        symptoms.contains { $0.needsAdvice }
    }

    var body: some View {
        NavigationStack {
            Form {
                resume
                comfortSection
                journal
                if needsAdvice {
                    adviceSection
                }
                haikuSection
                noteSection
            }
            .navigationTitle("C'est noté")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ignorer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") { save() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    // MARK: - Sections

    private var resume: some View {
        Section {
            HStack {
                Label("Durée", systemImage: "timer")
                Spacer()
                Text(WCFormat.duration(session.finalDuration ?? 0))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            HStack {
                Label("Lieu", systemImage: session.place.symbol)
                Spacer()
                Text(session.place.title).foregroundStyle(.secondary)
            }
            HStack {
                Label("Type", systemImage: session.kind.symbol)
                Spacer()
                Text(session.kind.title).foregroundStyle(.secondary)
            }
        } header: {
            Text("Visite enregistrée")
        }
    }

    private var comfortSection: some View {
        Section("Confort") {
            ComfortRating(value: $comfort)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 4)
        }
    }

    private var journal: some View {
        Section {
            Picker("Consistance", selection: $bristol) {
                Text("Non renseignée").tag(Bristol?.none)
                ForEach(Bristol.allCases) { type in
                    Text("\(type.title) · \(type.detail)").tag(Bristol?.some(type))
                }
            }
            .pickerStyle(.navigationLink)

            if let bristol {
                HStack {
                    Text(bristol.tendency.title)
                        .font(.footnote)
                        .foregroundStyle(bristol.isNotable ? WCTheme.warn : .secondary)
                    Spacer()
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Effort")
                    Spacer()
                    Text(effort == 0 ? "—" : "\(effort)/5")
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Slider(
                    value: Binding(get: { Double(effort) }, set: { effort = Int($0.rounded()) }),
                    in: 0...5,
                    step: 1
                )
            }

            ForEach(Symptom.allCases) { symptome in
                Toggle(isOn: Binding(
                    get: { symptoms.contains(symptome) },
                    set: { actif in
                        if actif { symptoms.insert(symptome) } else { symptoms.remove(symptome) }
                    }
                )) {
                    Label(symptome.title, systemImage: symptome.symbol)
                }
            }
        } header: {
            Text("Journal")
        } footer: {
            Text("L'échelle de Bristol est la classification usuelle de la consistance. Ces notes servent à suivre une évolution, et à la montrer à un professionnel si besoin.")
        }
    }

    private var adviceSection: some View {
        Section {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(WCTheme.warn)
                Text("Du sang dans les selles justifie un avis médical, même une seule fois. Ce n'est pas une urgence en soi, mais ça se regarde.")
                    .font(.footnote)
            }
        }
    }

    private var haikuSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(HaikuEngine.haiku(for: session).lines, id: \.self) { vers in
                    Text(vers).font(.callout.italic())
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("Haïku de la visite")
        } footer: {
            Text("Composé d'après la durée, l'heure et le lieu. Personne ne l'avait demandé.")
        }
    }

    private var noteSection: some View {
        Section("Note") {
            TextField("Optionnel", text: $note, axis: .vertical)
                .lineLimit(1...4)
        }
    }

    // MARK: - Enregistrement

    private func save() {
        var updated = session
        updated.comfort = comfort > 0 ? comfort : nil
        updated.bristol = bristol
        updated.effort = effort > 0 ? effort : nil
        updated.symptoms = symptoms.isEmpty ? nil : Symptom.allCases.filter { symptoms.contains($0) }
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.note = trimmed.isEmpty ? nil : trimmed
        onSave(updated)

        // Dépôt dans l'app Santé, si l'utilisateur l'a autorisé.
        let aExporter = updated
        Task { await health.export(aExporter) }

        dismiss()
    }
}

#Preview {
    EndVisitSheet(
        session: ToiletSession(startedAt: .now.addingTimeInterval(-260), endedAt: .now),
        onSave: { _ in }
    )
}
