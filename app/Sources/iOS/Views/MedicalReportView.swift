import SwiftUI

/// Bilan à montrer en consultation : une page, des chiffres, aucune conclusion.
struct MedicalReportView: View {
    @EnvironmentObject private var store: SessionStore

    @State private var days = MedicalReportEngine.windowDays
    @State private var image: Image?

    private var report: MedicalReport {
        MedicalReportEngine.build(sessions: store.sessions, days: days)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Période", selection: $days) {
                    Text("30 jours").tag(30)
                    Text("60 jours").tag(60)
                    Text("90 jours").tag(90)
                }
                .pickerStyle(.segmented)

                if report.isEmpty {
                    Text("Aucune visite enregistrée sur cette période. Le bilan se remplit tout seul, une visite à la fois.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } else {
                    MedicalReportCard(report: report)

                    if let image {
                        ShareLink(
                            item: image,
                            preview: SharePreview("Bilan WC Connect", image: image)
                        ) {
                            Label("Partager le bilan", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button {
                            image = render(MedicalReportCard(report: report))
                        } label: {
                            Label("Préparer le bilan", systemImage: "doc.text")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.bordered)
                    }
                }

                Text("WC Connect n'est pas un dispositif médical. Ce bilan décrit ce que vous avez noté, rien de plus : l'interprétation revient à un professionnel.")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .navigationTitle("Bilan pour le médecin")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: days) { _, _ in
            // Une période changée invalide l'image déjà rendue.
            image = nil
        }
    }

    @MainActor
    private func render(_ card: some View) -> Image? {
        let renderer = ImageRenderer(content: card.frame(width: 360))
        renderer.scale = 3
        guard let image = renderer.uiImage else { return nil }
        return Image(uiImage: image)
    }
}

/// La page du bilan, rendue à l'écran comme en image.
struct MedicalReportCard: View {
    let report: MedicalReport

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Bilan des %@ derniers jours".wcLocalized(String(report.daysCovered)))
                    .font(.headline)
                Text(periode)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            VStack(spacing: 8) {
                ligne("Visites".wcLocalized, value: String(report.visits))
                ligne("Jours avec visite".wcLocalized, value: "%@ sur %@".wcLocalized(
                    String(report.daysWithVisit), String(report.daysCovered)
                ))
                ligne("Fréquence".wcLocalized, value: "%@ par semaine".wcLocalized(
                    String(format: "%.1f", report.visitsPerWeek)
                ))
                ligne("Plus longue absence".wcLocalized, value: WCFormat.days(report.longestGapDays))
                ligne("Durée moyenne".wcLocalized, value: WCFormat.duration(report.averageDuration))
                if let effort = report.averageEffort {
                    ligne("Effort moyen".wcLocalized, value: "%@/5".wcLocalized(String(format: "%.1f", effort)))
                }
            }

            if !report.byBristol.isEmpty {
                section("Consistance".wcLocalized) {
                    VStack(spacing: 6) {
                        ligne(Bristol.Tendency.constipation.title, value: String(report.count(of: .constipation)))
                        ligne(Bristol.Tendency.ideal.title, value: String(report.count(of: .ideal)))
                        ligne(Bristol.Tendency.loose.title, value: String(report.count(of: .loose)))
                    }
                }
            }

            if !report.bySymptom.isEmpty {
                section("Symptômes notés".wcLocalized) {
                    VStack(spacing: 6) {
                        ForEach(Symptom.allCases) { symptome in
                            let compte = report.bySymptom[symptome] ?? 0
                            if compte > 0 {
                                ligne(
                                    symptome.title,
                                    value: String(compte),
                                    tint: symptome.needsAdvice ? WCTheme.warn : nil
                                )
                            }
                        }
                    }
                }
            }

            if !report.notableSymptoms.isEmpty {
                Text("Un ou plusieurs symptômes notés justifient un avis médical.")
                    .font(.caption)
                    .foregroundStyle(WCTheme.warn)
            }

            Text("WC Connect")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
    }

    private var periode: String {
        let debut = report.from.formatted(.dateTime.day().month(.abbreviated))
        let fin = report.to.formatted(.dateTime.day().month(.abbreviated).year())
        return "%@ – %@".wcLocalized(debut, fin)
    }

    private func ligne(_ titre: String, value valeur: String, tint: Color? = nil) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(titre)
                .font(.subheadline)
                .foregroundStyle(tint ?? .primary)
            Spacer(minLength: 12)
            Text(valeur)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
    }

    // Générique explicite : `some View` imbriqué dans un type de fonction
    // n'est pas accepté en position de paramètre.
    private func section<Contenu: View>(
        _ titre: String,
        @ViewBuilder contenu: () -> Contenu
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            Text(titre)
                .font(.caption.weight(.semibold))
                .textCase(.uppercase)
                .foregroundStyle(.secondary)
            contenu()
        }
    }
}

#Preview {
    NavigationStack {
        MedicalReportView().environmentObject(SessionStore.preview)
    }
}
