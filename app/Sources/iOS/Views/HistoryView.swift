import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var store: SessionStore
    @State private var filter: Place?
    @State private var editing: ToiletSession?

    private var groups: [(day: Date, sessions: [ToiletSession])] {
        store.groupedByDay.compactMap { group in
            guard let filter else { return group }
            let filtered = group.sessions.filter { $0.place == filter }
            return filtered.isEmpty ? nil : (day: group.day, sessions: filtered)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if let active = store.active {
                    Section("En cours") {
                        SessionRow(session: active)
                    }
                }

                ForEach(groups, id: \.day) { group in
                    Section {
                        ForEach(group.sessions) { session in
                            Button {
                                editing = session
                            } label: {
                                SessionRow(session: session)
                            }
                            .buttonStyle(.plain)
                            .swipeActions {
                                Button(role: .destructive) {
                                    store.delete(session)
                                } label: {
                                    Label("Supprimer", systemImage: "trash")
                                }
                            }
                        }
                    } header: {
                        HStack {
                            Text(WCFormat.dayHeader(group.day))
                            Spacer()
                            Text("\(group.sessions.count) visite\(group.sessions.count > 1 ? "s" : "")")
                        }
                    }
                }

                if groups.isEmpty && store.active == nil {
                    ContentUnavailableView(
                        "Aucune visite",
                        systemImage: "toilet",
                        description: Text("Les visites enregistrées depuis l'iPhone, la Watch ou un widget apparaîtront ici.")
                    )
                }
            }
            .navigationTitle("Historique")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Picker("Lieu", selection: $filter) {
                            Text("Tous les lieux").tag(Place?.none)
                            ForEach(Place.allCases, id: \.self) { place in
                                Label(place.title, systemImage: place.symbol).tag(Place?.some(place))
                            }
                        }
                    } label: {
                        Label("Filtrer", systemImage: filter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                    }
                }
            }
            .sheet(item: $editing) { session in
                EndVisitSheet(session: session) { updated in
                    store.update(updated)
                }
            }
        }
    }
}

#Preview {
    HistoryView().environmentObject(SessionStore.preview)
}
