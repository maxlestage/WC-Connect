import SwiftUI

/// Feuille d'annotation affichée juste après la fin d'une visite.
struct EndVisitSheet: View {
    let session: ToiletSession
    let onSave: (ToiletSession) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var comfort: Int
    @State private var note: String

    init(session: ToiletSession, onSave: @escaping (ToiletSession) -> Void) {
        self.session = session
        self.onSave = onSave
        _comfort = State(initialValue: session.comfort ?? 0)
        _note = State(initialValue: session.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
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

                Section("Confort") {
                    ComfortRating(value: $comfort)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                }

                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(HaikuEngine.haiku(for: session).lines, id: \.self) { vers in
                            Text(vers)
                                .font(.callout.italic())
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Haïku de la visite")
                } footer: {
                    Text("Composé d'après la durée, l'heure et le lieu. Personne ne l'avait demandé.")
                }

                Section("Note") {
                    TextField("Optionnel", text: $note, axis: .vertical)
                        .lineLimit(1...4)
                }
            }
            .navigationTitle("C'est noté")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Ignorer") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        var updated = session
                        updated.comfort = comfort > 0 ? comfort : nil
                        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
                        updated.note = trimmed.isEmpty ? nil : trimmed
                        onSave(updated)
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    EndVisitSheet(
        session: ToiletSession(startedAt: .now.addingTimeInterval(-260), endedAt: .now),
        onSave: { _ in }
    )
}
